﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ПроверкаРолиНаСервере.ЕстьРоль("Директор") Тогда
		УстановитьПривилегированныйРежим(Истина);
		Объект.Заведение = ПараметрыСеанса.ТекущийСотрудник.Заведение;
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПродуктыКоличествоПриИзменении(Элемент)
	РасчетЦены();	
КонецПроцедуры

&НаКлиенте
Процедура ПродуктыЦенаПриИзменении(Элемент)
	РасчетЦены();
КонецПроцедуры 

&НаКлиенте
Процедура РасчетЦены()
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	ТекущиеДанные.Сумма = ТекущиеДанные.Количество * ТекущиеДанные.Цена;
	
	Скидка = Число(СтрЗаменить(ТекущиеДанные.Скидка, "%", "")); 
    ТекущиеДанные.ИтоговаяСумма = ТекущиеДанные.Сумма * (1 - Скидка / 100);

    ПерерасчетСуммДокумента();
		
КонецПроцедуры

&НаКлиенте
Процедура ПродуктыСуммаПриИзменении(Элемент)
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные; 
	Если ТекущиеДанные.Цена <> 0 Тогда
		ТекущиеДанные.Количество = ТекущиеДанные.Сумма / ТекущиеДанные.Цена;
		МожетБытьДробным = ПерерасчетСуммКлиент.МожетБытьДробным(ТекущиеДанные.ЕдиницаИзмерения);
		Если НЕ МожетБытьДробным Тогда
			ТекущиеДанные.Количество = Цел(ТекущиеДанные.Количество);
			Если ТекущиеДанные.Количество <> 0 Тогда
				ТекущиеДанные.Цена = ТекущиеДанные.Сумма / ТекущиеДанные.Количество;
			Иначе
				РасчетЦены();
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЕсли;
	
	ПерерасчетСуммДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура ДоговорПриИзменении(Элемент)
	ПерерасчетСкидокНаПродукты();
КонецПроцедуры

&НаСервере
Функция ПродуктыПродуктПриИзмененииНаСервере(Продукт)
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СкидкиНаПродуктыСрезПоследних.Скидка КАК Скидка
	|ИЗ
	|	РегистрСведений.СкидкиНаПродукты.СрезПоследних(&ДатаДокумента,) КАК СкидкиНаПродуктыСрезПоследних
	|ГДЕ
	|	СкидкиНаПродуктыСрезПоследних.Продукт.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("ДатаДокумента", Объект.Дата);
	Запрос.УстановитьПараметр("Ссылка", Продукт);
	
	Выборка = Запрос.Выполнить().Выбрать();
 	Выборка.Следующий();
	
	Скидка = Выборка.Скидка;
	
	Возврат Скидка;
	
КонецФункции

&НаКлиенте
Процедура ПродуктыПродуктПриИзменении(Элемент)
	Продукт = Элементы.Товары.ТекущиеДанные.Номенклатура;
	СкидкаПродукта = ПродуктыПродуктПриИзмененииНаСервере(Продукт);
	СкидкаДоговора = ПерерасчетСуммКлиент.ПолучитьСкидкуИзДоговора(Объект.Договор, Объект.Дата);
	Если СкидкаДоговора = Неопределено Тогда
		ВариантСкидки = ПерерасчетСуммКлиент.ПолучитьСкидку(Объект.Договор);
		СкидкаДоговора = ПосчитатьСкидку(ВариантСкидки);
	КонецЕсли;
	ИтоговаяСкидка = 0;
	Если СкидкаПродукта <> Неопределено И СкидкаПродукта > СкидкаДоговора Тогда
		ИтоговаяСкидка = СкидкаПродукта;
	Иначе
		ИтоговаяСкидка = СкидкаДоговора;  
	КонецЕсли; 
	
	Элементы.Товары.ТекущиеДанные.Скидка = "" + ИтоговаяСкидка + "%";
	Элементы.Товары.ТекущиеДанные.ИтоговаяСумма = Элементы.Товары.ТекущиеДанные.Сумма * (1 - ИтоговаяСкидка / 100);
	
	ПерерасчетСуммДокумента();
КонецПроцедуры   

&НаКлиенте
Процедура ПерерасчетСуммДокумента()
	Продукты = Объект.Товары;
	Объект.СуммаДоСкидки = Продукты.Итог("Сумма");
	Объект.СуммаДокумента = Продукты.Итог("ИтоговаяСумма");	
КонецПроцедуры   


&НаКлиенте
Процедура ПерерасчетСкидокНаПродукты()
	Продукты = Объект.Товары;
	МассивПродуктов = Новый Массив;
	Для Каждого Строка Из Продукты Цикл
		МассивПродуктов.Добавить(Строка.Продукт);
	КонецЦикла;
	
	СкидкиНаПродукты = ПерерасчетСуммКлиент.ПолучитьСкидкиНаПродукты(МассивПродуктов, Объект.Дата);
	СкидкаДоговора = ПерерасчетСуммКлиент.ПолучитьСкидкуИзДоговора(Объект.Договор, Объект.Дата);
	Если СкидкаДоговора = Неопределено Тогда
		ВариантСкидки = ПерерасчетСуммКлиент.ПолучитьСкидку(Объект.Договор);
		СкидкаДоговора = ПосчитатьСкидку(ВариантСкидки);
	КонецЕсли;
	
	Для Каждого Строка Из Продукты Цикл
		СкидкаПродукта = СкидкиНаПродукты[Строка.Продукт];
		ИтоговаяСкидка = 0;
		Если СкидкаПродукта <> Неопределено И СкидкаПродукта > СкидкаДоговора Тогда
			ИтоговаяСкидка = СкидкаПродукта;
		Иначе
			ИтоговаяСкидка = СкидкаДоговора;
		КонецЕсли;
		Строка.Скидка = "" + ИтоговаяСкидка + "%";
		Строка.ИтоговаяСумма = Строка.Сумма * (1 - ИтоговаяСкидка / 100);
	КонецЦикла;
	
	ПерерасчетСуммДокумента();
КонецПроцедуры





