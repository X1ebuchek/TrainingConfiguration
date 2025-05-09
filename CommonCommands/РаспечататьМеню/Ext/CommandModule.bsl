﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды) 
	
	ТабДок = Новый ТабличныйДокумент;
	Печать(ТабДок, ПараметрКоманды);

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ТолькоПросмотр = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.Показать();
	
КонецПроцедуры    

&НаСервере
Процедура Печать(ТабДок, Ссылка) Экспорт
	
	Макет = ПолучитьОбщийМакет("МакетМеню");
	
	//Запрос
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	БлюдаСостав.Продукт КАК Продукт,
		|	БлюдаСостав.Ссылка.КБЖУ КАК КБЖУ,
		|	БлюдаСостав.Ссылка КАК Ссылка,
		|	БлюдаСостав.Ссылка.Описание КАК Описание,
		|	БлюдаСостав.Ссылка.Родитель КАК Родитель
		|ПОМЕСТИТЬ ВтБлюдаИСостав
		|ИЗ
		|	Справочник.Блюда.Состав КАК БлюдаСостав
		|ГДЕ
		|	БлюдаСостав.Ссылка.ПометкаУдаления = ЛОЖЬ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЦеныБлюдСрезПоследних.Блюдо КАК Блюдо,
		|	ЦеныБлюдСрезПоследних.Цена КАК Цена
		|ПОМЕСТИТЬ ВТЦены
		|ИЗ
		|	РегистрСведений.ЦеныБлюд.СрезПоследних(
		|			&ТекущаяДата,
		|			Блюдо В
		|				(ВЫБРАТЬ
		|					ВтБлюдаИСостав.Ссылка КАК Ссылка
		|				ИЗ
		|					ВтБлюдаИСостав КАК ВтБлюдаИСостав)) КАК ЦеныБлюдСрезПоследних
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Блюдо
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВтБлюдаИСостав.Продукт КАК Продукт,
		|	ВтБлюдаИСостав.КБЖУ КАК КБЖУ,
		|	ВтБлюдаИСостав.Ссылка КАК Ссылка,
		|	ВЫРАЗИТЬ(ВтБлюдаИСостав.Описание КАК СТРОКА(1000)) КАК Описание,
		|	ВтБлюдаИСостав.Родитель КАК Родитель,
		|	ЕСТЬNULL(ВТЦены.Цена, 0) КАК Цена,
		|	ВтБлюдаИСостав.Продукт.Представление КАК ПродуктПредставление,
		|	ВтБлюдаИСостав.Ссылка.Представление КАК СсылкаПредставление,
		|	ВтБлюдаИСостав.Родитель.Представление КАК РодительПредставление
		|ИЗ
		|	ВтБлюдаИСостав КАК ВтБлюдаИСостав
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТЦены КАК ВТЦены
		|		ПО ВтБлюдаИСостав.Ссылка = ВТЦены.Блюдо
		|ИТОГИ
		|	МАКСИМУМ(КБЖУ),
		|	МАКСИМУМ(Описание),
		|	МАКСИМУМ(Цена)
		|ПО
		|	Родитель,
		|	Ссылка";
	
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаРодитель = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаРодитель.Следующий() Цикл
	
		ВыборкаСсылка = ВыборкаРодитель.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
		Пока ВыборкаСсылка.Следующий() Цикл

	
			ВыборкаДетальныеЗаписи = ВыборкаСсылка.Выбрать();
	
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
	//Получение областей

	//Очистить документ

	//Обход выборки
	
		//Выводим области в табличный документ 
		
КонецПроцедуры

