--[[
НАЗВАНИЕ
    Morning_sale_V132

ОПИСАНИЕ
    Данный скрипт представляет из себя торгового робота на платформе QUIK
	
	Утром, в момент открытия биржи 10.00:
	1. Проверяем цену лота в 10.00.10 (время выставляется в настройках) по открытым  позициям, 
		сравнивая с ценой лота в момент открытия биржи в 10.00.00:
	1. Если текущая цена лота ниже цены лота в 10.00.00, то ордер закрываем 
	2. Если цена лота выше цены лота в  10.00.00, то 
	   выставляем отложенный ордер тэйкпрофит по условию +36% от текущей цены лота на закрытие 
	   (процент задаётся в настройках для каждой позиции)
	3. При ненаступлении условия по проценту до конца рабочего дня ордер удаляется и на утро всё повторяется с пункта 1 .
	
	Параметры в столбцах, отмеченных зелёным цветом, являются настраиваемыми. 
	
	В версии 1.3.2 добавлена возможность ввода дробного значения для колонки "Процент для отложенного ордера".  
	В версии 1.3.3 изменен алгоритм определения цены открытия. 
ВЕРСИЯ
    1.3.3

РАЗРАБОТЧИК
    Машкин Руслан (https://t.me/ruslan_mashkin )

Дата создания
    27.09.2023
]]--



------------------------------------------------- Инициализируем глобальные переменные --------------------------
local account = ""                         -- основной счет
local client_code = ""                     -- код клиента
local script_name = "Morning_sale_V1"      -- название скрипта
local is_running = true                    -- флаг, указывающий работает ли скрипт
local is_stopped = false                   -- флаг, указывающий остановлен ли скрипт
local row_new_instrument = 0               -- номер строки в таблице, где новый инструмент
local clicked_row = 0                      -- номер строки в главной таблице, где был клик
local clicked_another_row = 0              -- номер строки в других таблицах, где был клик
local additional_window_height = 0         -- высота дополнительных окон
local main_window_height = 0               -- высота главного окна
local main_window_width = 0                -- ширина главного окна
local main_window_x_coord = 0              -- X-координата главного окна
local main_window_y_coord = 0              -- Y-координата главного окна
local rows_in_main_window = 0              -- количество строк главного окна
local cols_in_main_window = 0              -- количество колонок главного окна
local current_row_number = 0               -- текущий номер строки в таблице
local current_column_number = 0            -- текущий номер столбца в таблице 
local user_input = ""                      -- строка ввода пользователя
local native_folder_path = ""              -- путь к папке
local current_second = 0                   -- для определения секунды в системном вререни
local Class_Code = ""                      -- класс торгуемого инструмента
local Sec_Code = ""                        -- код торгуемого инструмента
local g_lots = 1                           -- количество торгуемых лот

local timeRange = 3                        -- временной диапазон в каторый может произойти сделка (сек)
local start_work_time = 100000             -- время начала торговой сессии в формате ЧЧММСС
local finish_work_time = 183959            -- время окончания торговой сессии в формате ЧЧММСС
local check_time = 100000                  -- время ввиде числа в которое фиксируется цена для будущего сравнения 


local csv_file_name = script_name.."_main_window.csv"  -- имя файла для сохранения таблицы окна
local separator = ","                      -- разделитель в csv

-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- Инициализируем рабочие таблицы --------------------------------

-- Создаем основную таблицу
QTable = {}
QTable.__index = QTable

-- Создаем таблицу классов
Class_Table = {}
Class_Table.__index = Class_Table

-- Создаем таблицу инструментов
Sec_Table = {}
Sec_Table.__index = Sec_Table

-- Создаем таблицу информации
Inf_Table = {}
Inf_Table.__index = Inf_Table

-- Создаем таблицу действий
Task_Table = {}
Task_Table.__index = Task_Table

-- Создаем таблицу торгового счета
Account_Table = {}
Account_Table.__index = Account_Table

-- Создаем таблицу кода клиента
CLIENT_CODE_Table = {}
CLIENT_CODE_Table.__index = CLIENT_CODE_Table

-- Создаем таблицу подтверждения
Confirmation_Table = {}
Confirmation_Table.__index = Confirmation_Table

-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- Функции скрипта -----------------------------------------------

function OnStop()
--[[
НАЗВАНИЕ
    Обработчик события OnStop()

ОПИСАНИЕ
    Данный обработчик вызывается при остановке торгового робота на платформе QUIK.
	В функции происходит удаление всех созданных таблиц и установка флага is_stopped в true.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]--
    -- Устанавливаем флаг остановки скрипта
    is_stopped = true
    
    -- Устанавливаем флаг работы скрипта как false
    is_running = false
	
    -- Удаляем созданные таблицы
	DestroyTable(t_id)
	DestroyTable(c_id)
	DestroyTable(s_id)	
	DestroyTable(inf_id)
	DestroyTable(task_id)
	DestroyTable(a_id)
	DestroyTable(cc_id)
	DestroyTable(conf_id)
	
end

function OnInit(p_)
--[[
НАЗВАНИЕ: OnInit

ОПИСАНИЕ:
    Данная функция вызывается при запуске торгового робота на платформе QUIK.

ПАРАМЕТРЫ:
    p_ - строка. Путь к папке, в которой хранится скрипт.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ:
    Нет возвращаемых значений.
]]--

	native_folder_path = tostring(p_)
end

function main()
--[[
НАЗВАНИЕ
    Главная функция скрипта - main()

ОПИСАНИЕ
    Данная функция запускает главное окно с таблицей.
    Затем функция начинает выполнять основной код скрипта, который выполняется в бесконечном цикле. 
    Если флаг is_stopped установлен в true, то функция завершает работу, бот останавливается.
    Иначе функция вызывает функцию Table_UpDate(), которая обновляет данные в таблице и выполняет необходимые действия.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений
]]--
	InitTable()                                   -- Запускаем окно с таблицей
	sleep(10) 
	local sr=SetSelectedRow(t_id, 1)              -- Переводим фокус на первую строку
	while is_running do                           -- Безконечный цикл
		if is_stopped then                        -- Если флаг остановки установлен, то выходим из цикла
			return
		end
		sleep(5)                                  -- Задержка
		Table_UpDate()                            -- Обновляем данные в таблице
		d1, d2 = {}, {}                           -- таблицы для работы с данными главного окна
		d1 = prepareData()                        -- текущее состояние главного окна
		d2 = readCSV(csv_file_name, separator)    -- сохраненное состояние главного окна
		if tableEqual(d1, d2) then                -- сравнение таблиц
			--message("ТАБЛИЦЫ Равны")
		else
			--message("ТАБЛИЦЫ НЕ Равны")
			if is_running then
				saveMainWindowTableToCSV()        -- если в главном окне прозошли изменения то сохраняемся
			end
		end

	end  --while
end  --function

function To_integer(n)
--[[
НАЗВАНИЕ
    Функция преобразования любого числа в целое число - To_integer()

ОПИСАНИЕ
    Данная функция получает на вход любое число и преобразует его в целое число. 
    Если преобразование не удалось, то функция возвращает значение nil.

ПАРАМЕТРЫ
    Аргументы функции:
    * n - любое число , которое нужно преобразовать в целое число.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращаемое значение:
    * Целое число, если преобразование удалось, или nil, если не удалось.
]]--
	return math.tointeger(tonumber(n))
end

function UpdateWindowTitle()
--[[
НАЗВАНИЕ
    Функция обновления заголовка окна - UpdateWindowTitle()

ОПИСАНИЕ
    Данная функция обновляет заголовок главного окна, добавляя к нему текущее время в формате часы:минуты:секунды.
	Это нужно в том числе для индикации работы скрипта 
ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]--
	if current_second ~= tonumber(os.date("%S")) then                           -- проверяем, изменилась ли текущая секунда
		current_second = tonumber(os.date("%S"))                                -- если изменилась, то обновляем значение переменной
		SetWindowCaption(tt, script_name.."         "..tostring(os.date("%X"))) -- обновляем заголовок окна
	end
end


function isValidPositiveNumber(n)
--[[
НАЗВАНИЕ
    Функция проверки корректности значения переменной - isValidPositiveNumber()
	
ОПИСАНИЕ
    Данная функция проверяет корректность переданного значения переменной.
	
ПАРАМЕТРЫ
    Аргументы функции:
    * n - проверяемое значение переменной.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    * Возвращает true, если переданное значение корректно (число не меньше 0), иначе - false.
]]  
	local res = false                                           -- устанавливаем значение результата в ложь
	if n == nil or type(n) == "string" or n == "" or n <0 then  -- проверяем значение на nil, тип "string", пустую строку и отрицательные/нулевые числа
		res = false                                             -- если значение не соответствует требованиям, то устанавливаем результат в ложь
	else
		res = true                                              -- иначе устанавливаем результат в истину
	end
	return res                                                  -- возвращаем результат выполнения функции
end



function Last_price(class, sec)
--[[
НАЗВАНИЕ
    Last_price - функция получения текущей цены заданного инструмента.

ОПИСАНИЕ
    Данная функция возвращает текущую цену заданного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, текущая цена заданного инструмента.
]]
	return tonumber(getParamEx(class, sec, "LAST").param_value)
end

function Lot_size(class, sec)
--[[
НАЗВАНИЕ
    Lot_size - функция получения количества бумаг в лоте инструмента.

ОПИСАНИЕ
    Данная функция возвращает количество бумаг в лоте заданного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Целое число, количество бумаг в лоте заданного инструмента.
]]
    return tonumber(getParamEx(class, sec, "LOTSIZE").param_value)
end



function Min_price_step(class, sec)
--[[
НАЗВАНИЕ
    Min_price_step - функция получения минимального шага цены для выбранного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, минимальный шаг цены для переданного инструмента.
]]
	return tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- минимальный шаг цены

end




function CheckAllCellsFilled(i)
--[[
НАЗВАНИЕ
    CheckAllCellsFilled - функция проверки заполнения всех ячеек в строке таблицы.

ОПИСАНИЕ
    Данная функция проверяет заполнение всех ячеек в конкретной строке таблицы.

ПАРАМЕТРЫ
    i (number) - номер строки в таблице.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если все ячейки заполнены корректно, иначе - false.
]]
	-- Инициализация переменной для хранения результата проверки.
	local res = false

	-- Получение значений из ячеек таблицы.
	local a = tonumber(GetCell(tt, i, 7)["image"])   
	local b = tonumber(GetCell(tt, i, 8)["image"])           
	local c = tonumber(GetCell(tt, i, 9)["image"])
	local d = tonumber(GetCell(tt, i, 11)["image"]) 
	-- local e = tonumber(GetCell(tt, i, 12)["image"])
	-- local f = tonumber(GetCell(tt, i, 13)["image"])
	-- local l = tonumber(GetCell(tt, i, 5)["image"])
	-- local time_today = getBuysTimeAsNumber(i)
	-- local time_tomorrow = getSellsTimeAsNumber(i)

	-- Проверка корректности заполнения ячеек, вызов функции isValidPositiveNumber для каждой из них.
	if isValidPositiveNumber(a) and 
	isValidPositiveNumber(b) and 
	isValidPositiveNumber(c) and 
	isValidPositiveNumber(d)
	-- isValidPositiveNumber(e) and 
	-- isValidPositiveNumber(l) and 
	-- isValidPositiveNumber(f) 
	then
		res = true
	end
  
	-- Возврат значения результата проверки.
	return res
end

function MarketBuy(class, sec, number_lots)
--[[
НАЗВАНИЕ
    MarketBuy - функция открытия позиции путем рыночной покупки.

ОПИСАНИЕ
    Данная функция осуществляет открытие позиции путем рыночной покупки инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- Код класса
		SECCODE = sec,      		            -- Код инструмента	
		ACCOUNT = account,   			        -- Код счета
		TYPE = "M",        		                -- Тип ('L' - лимитированная, 'M' - рыночная)
		TRANS_ID = tostring(os.time()),         -- Номер транзакции
		OPERATION = "B",         			    -- Операция ('B' - buy, или 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- Количество
		PRICE = "0",                            -- Цена
		ACTION = "NEW_ORDER"                    -- Тип транзакции ('NEW_ORDER' - новая заявка)
	}
	local res = sendTransaction(trans_params)   -- отправка транзакции
	if is_running and string.len(res) ~= 0 then -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 
end

function MarketSell(class, sec, number_lots)
--[[
НАЗВАНИЕ
    MarketSell - функция закрытия позиции путем рыночной продажи.

ОПИСАНИЕ
    Данная функция осуществляет закрытие позиции путем рыночной продажи инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- Код класса
		SECCODE = sec,      		            -- Код инструмента	
		ACCOUNT = account,   			        -- Код счета
		TYPE = "M",        		                -- Тип ('L' - лимитированная, 'M' - рыночная)
		TRANS_ID = tostring(os.time()),         -- Номер транзакции
		OPERATION = "S",         			    -- Операция ('B' - buy, или 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- Количество
		PRICE = "0",                            -- Цена
		ACTION = "NEW_ORDER"                    -- Тип транзакции ('NEW_ORDER' - новая заявка)
	}
	local res = sendTransaction(trans_params)   -- отправка транзакции
	if is_running and string.len(res) ~= 0 then -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 

end


function DelayedOrderSell(class, sec, number_lots, price)
--[[
НАЗВАНИЕ
    Delayed_Order - функция выставления отложенного ордера типа Тэйк-Профит.

ОПИСАНИЕ
    Данная функция осуществляет выставление отложенного ордера типа Тэйк-Профит путем отправки транзакции на биржу.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов
    price (number) - цена тэйк-профита

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.


]]
	local trans_params =
		{
		["ACTION"]              = "NEW_STOP_ORDER",         -- Тип заявки
		["TRANS_ID"]            = tostring(os.time()),      -- Номер транзакции
		["CLASSCODE"]           = class,
		["SECCODE"]             = sec,
		["ACCOUNT"]             = account,
		["OPERATION"]           = "S",                      -- Операция ("B" - покупка(BUY), "S" - продажа(SELL))
		["QUANTITY"]            = tostring(number_lots),    -- Количество в лотах
		["PRICE"]               = tostring(0),              -- Цена, по которой выставится заявка при срабатывании Стоп-Лосса (для рыночной заявки по акциям должна быть 0)
		["STOPPRICE"]           = tostring(price),          -- Цена Тэйк-Профита
		["STOP_ORDER_KIND"]     = "TAKE_PROFIT_STOP_ORDER", -- Тип стоп-заявки
		["EXPIRY_DATE"]         = "TODAY",                  -- Срок действия стоп-заявки ("GTC" – до отмены,"TODAY" - до окончания текущей торговой сессии, Дата в формате "ГГММДД")
		["OFFSET"]              = tostring(0),
		["OFFSET_UNITS"]        = "PERCENTS",               -- Единицы измерения отступа ("PRICE_UNITS" - шаг цены, или "PERCENTS" - проценты)
		["SPREAD"]              = tostring(0),
		["SPREAD_UNITS"]        = "PERCENTS",               -- Единицы измерения защитного спрэда ("PRICE_UNITS" - шаг цены, или "PERCENTS" - проценты)
      -- "MARKET_TAKE_PROFIT" = ("YES", или "NO") должна ли выставится заявка по рыночной цене при срабатывании Тэйк-Профита.
      -- Для рынка FORTS рыночные заявки, как правило, запрещены,
      -- для лимитированной заявки на FORTS нужно указывать заведомо худшую цену, чтобы она сработала сразу же, как рыночная
	    --["MARKET_TAKE_PROFIT"]  = "YES",
		["STOPPRICE2"]          = tostring(0),              -- Цена Стоп-Лосса 
		["IS_ACTIVE_IN_TIME"]   = "NO",
		["CLIENT_CODE"]         = tostring(client_code)
		}
	local res = sendTransaction(trans_params)
	if is_running and string.len(res) ~= 0 then           -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 
end


function Delete_Delayed_Order(class, sec)
--[[

НАЗВАНИЕ
    Delete_Delayed_Order - функция удаления отложенной заявки.

ОПИСАНИЕ
    Данная функция осуществляет удаление отложенной заявки на сделку.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true - если транзакция была выполнена
    false - если транзакция не была выполнена

]]
	for i = 0,getNumberOf("stop_orders") - 1 do                     -- Перебираются все отложенные заявки на сделку, которые находятся в таблице "stop_orders"
		if getItem("stop_orders",i).sec_code == sec then            -- Если строка по нужному инструменту не равна нулю
			order=getItem("stop_orders",i).flags
			if bit.band(order,1)>0 then                             -- Если отложенная заявка - это стоп-заявка типа "Тейк-профит" (битовая маска с номером 1)
				order_num = getItem("stop_orders",i).order_num      -- Получение номера заявки
				local trans_params =                                -- Создание таблицы параметров транзакции
					{
					["ACTION"] = "KILL_STOP_ORDER",                 -- Действие - удаление отложенной заявки
					["TRANS_ID"] = tostring(os.time()),             -- Уникальный идентификатор транзакции
					["CLASSCODE"] = class,                          -- Код класса инструмента
					["SECCODE"] = sec,                              -- Код инструмента
					["ACCOUNT"] = account,                          -- Номер счета
					["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER", -- Тип стоп-заявки (Тейк-профит)
					["CLIENT_CODE"] = tostring(client_code),        -- Код клиента
					['STOP_ORDER_KEY'] = tostring(order_num)        -- Номер удаляемой заявки
					}
				local res = sendTransaction(trans_params)           -- Отправление транзакции на удаление отложенной заявки
				if is_running and string.len(res) ~= 0 then         -- Если транзакция не выполнена
					message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- Вывод сообщения об ошибке
					return false -- Возвращается false
				else -- Иначе
					return true -- Возвращается true
				end 
			end
		end
	end  
end
 
function getSellsTimeAsNumber(i)
--[[
НАЗВАНИЕ
    getSellsTimeAsNumber - функция получения времени продажи из ячеек таблицы.

ОПИСАНИЕ
    Данная функция извлекает информацию о времени продажи из ячеек таблицы и преобразует ее в числовое значение.

ПАРАМЕТРЫ
    i (number) - номер строки в таблице.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Числовое значение времени покупки в формате "HHMMSS".
]]
	local hh = tonumber(GetCell(tt, i, 7)["image"]) 
	local mm = tonumber(GetCell(tt, i, 8)["image"])
	local ss = tonumber(GetCell(tt, i, 9)["image"])
	return tonumber(TimeConvertToNumber(tonumber(hh), tonumber(mm), tonumber(ss)))
end

function Table_UpDate()
--[[
НАЗВАНИЕ
    Table_UpDate - функция обновления данных в главной таблице.

ОПИСАНИЕ
    Данная функция обновляет данные в главной таблице и реализует основной алгоритм работы.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]  
	UpdateWindowTitle()                      -- обновляем заголовок главного окна
	
  
	for i = 1, rows_in_main_window - 1 do    -- перебор строк главной таблицы
		
		-- если строка с инструментом
		if is_running and tostring(GetCell(tt,i,3)["image"])~="" then
			-- Держим флаги купленности и проданности опущенными пока локальное время меньше заданного
		  
			local classcod = tostring(GetCell(tt,i,2)["image"])                        -- класс инструмента из таблицы
			local seccod = tostring(GetCell(tt,i,3)["image"])                          -- код инструмента из таблицы
			SetCell(tt, i, 5, tostring(To_integer(getLots(classcod, seccod, i))))      -- позиция по инструменту
			SetCell(tt, i, 6, tostring(OpenPrice(classcod, seccod)))                   -- цена при открытии
			
			----------------------------------------  Торговая логика  --------------------------------------------------
			
			if GetOn(i) then                                                                   -- если кнопка "Включить" нажата
				if CheckAllCellsFilled(i) then                                                 -- если все настраеваемые параметры заполнены
			
					LocalTimeAsNumber = getLocalTimeAsNumber()
					if LocalTimeAsNumber >= start_work_time then                               -- если рабочие время
						local lots = getLots(classcod, seccod, i) or 0                         -- число лотов в позиции
						if lots > 0 then                                                       -- если позиция существует
							if (LocalTimeAsNumber >= getSellsTimeAsNumber(i)) and
							(LocalTimeAsNumber <= (getSellsTimeAsNumber(i) + timeRange)) then  -- если время продажи
								if GetSold(i) == false then                                    -- если еще не выставлен флаг
									if IsHigherThanOpenPrice(classcod, seccod) then            -- если цена выше цены открытия
										local price = DelayedSellPrice(classcod, seccod, i)
										DelayedOrderSell(classcod, seccod, lots, price)        -- то отложенная продажа
										SetSold(i, 1)                                          -- зафиксировать продажу
									else
										MarketSell(classcod, seccod, lots)                     -- иначе продать по рынку
										SetSold(i, 1)                                          -- зафиксировать продажу
									end
								end
							else
								if                                                             -- если
								(LocalTimeAsNumber >= finish_work_time)                        -- рабочие время кончилось
								and                                                            -- и
								(GetSold(i) == true)                                           -- установлен флаг продажи
								then                                                           -- то
									Delete_Delayed_Order(classcod, seccod)                     -- снятие заявки
									SetSold(i, 0)                                              -- зафиксировать отмену продажы
								end	
							end
						
						end
					end
				end
			end
			-------------------------------------------------------------------------------------------------------------
		end
	end
end

function IsHigherThanOpenPrice(class, sec)
--[[
НАЗВАНИЕ
	IsCurrentPriceHigherThan10AM - функция сравнения текущей цены с ценой в 10:00:00.

ОПИСАНИЕ
    Данная функция сравнивает текущую цену с ценой открытия и возвращает значение true, если текущая цена выше.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если текущая цена выше цены в 10:00:00, иначе false (boolean).
]]  
	local currentPrice = Last_price(class, sec)         -- получаем текущую цену
	local price10AM = OpenPrice(class, sec)             -- получаем цену открытия
	if currentPrice == nil or price10AM == nil then
		return false
	end
	return currentPrice > (price10AM - minPriceStep(class, sec))
end

function CorrectPrice(class, sec, price)
  --[[
  НАЗВАНИЕ
    CorrectPrice - функция корректировки расчетной цены к виду, принимаемому системой.

  ОПИСАНИЕ
    Данная функция корректирует расчетную цену (price) к виду, принимаемому системой.
  
  ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.
    price (number) - расчетная цена.

  ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Корректированная цена (number).
  ]]--
  	local min_step_price = minPriceStep(class, sec)
	local res = math.floor(price / min_step_price) * min_step_price
	return math.abs(tonumber(res))
end

function minPriceStep(class, sec)
--[[
НАЗВАНИЕ
	minPriceStep - функция получения минимального шага цены для инструмента.

ОПИСАНИЕ
	Данная функция возвращает минимальный шаг цены для указанного инструмента.

ПАРАМЕТРЫ
	class (string) - код класса инструмента.
	sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
	Минимальный шаг цены (number).
]]--
	return tonumber(getParamEx(class, sec, "SEC_PRICE_STEP").param_value) -- минимальный шаг цены
end

function DelayedSellPrice(class, sec, i)
--[[
НАЗВАНИЕ
	DelayedSellPrice - функция расчета отложенной цены продажи.

ОПИСАНИЕ
	Данная функция рассчитывает отложенную цену продажи на основе  цены открытия и требуемого процента.

ПАРАМЕТРЫ
	class (string) - код класса инструмента.
	sec (string)   - код инструмента.
	i (number) - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
	отложенная цена продажи (number)
]] 
	local open_price = tonumber(GetCell(tt, i, 6)["image"])
	local percent = tonumber(GetCell(tt, i, 11)["image"])
	local price = open_price + (open_price / 100 * percent)
	return CorrectPrice(class, sec, price)
end

function getLots(class, sec, i)
--[[
НАЗВАНИЕ
	Функция getLots - получает число лотов для указанного инструмента.
ОПИСАНИЕ
	Данная функция получает количество лотов для заданного инструмента, 
	используя число бумаг в лоте и число бумаг в позиции. 
	
ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string)   - код инструмента.
    i (number)     - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
	количество лотов (number)
]]

	local lotSize = Lot_size(class, sec)
	local positionSize = tonumber(position_size(class, sec))
	return To_integer(positionSize / lotSize)
end

function fileExists(filename)
--[[
НАЗВАНИЕ
    fileExists - функция для проверки существования файла.

ОПИСАНИЕ
    Данная функция проверяет, существует ли файл с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, для которого нужно проверить существование.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Возвращает true, если файл существует, и false в противном случае.
]]
	local file = io.open(filename, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

function createFile(filename, content)
--[[
НАЗВАНИЕ
    createFile - функция для создания файла.

ОПИСАНИЕ
    Данная функция создает файл с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, который нужно создать.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Возвращает true, если файл успешно создан, и false в противном случае.
]]
	local file = io.open(filename, "w")
	if file then
		writeFile(filename, content)
		file:close()
		return true
	else
		message("Ошибка при создании файла")
		return false
	end
end

function readFile(filename)
--[[
НАЗВАНИЕ
    readFile - функция для чтения содержимого файла.

ОПИСАНИЕ
    Данная функция считывает содержимое файла с указанным именем.

ПАРАМЕТРЫ
    filename (string) - имя файла, содержимое которого нужно считать.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    string - Содержимое файла в виде строки. Если файл не найден, возвращается nil.
]]
	local file = io.open(filename, "r")
	if file then
		local content = file:read()
		file:close()
		return content
	else
		return nil
	end
end

function writeFile(filename, content)
--[[
НАЗВАНИЕ
    writeFile - функция для записи содержимого в файл.

ОПИСАНИЕ
    Данная функция записывает указанное содержимое в файл с указанным именем.
    Если файл не существует, он будет создан.

ПАРАМЕТРЫ
    filename (string) - имя файла, в который нужно записать содержимое.
    content (string) - содержимое, которое нужно записать в файл.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - true, если запись в файл прошла успешно, false - в противном случае.
]]
  local file = io.open(filename, "w")
  if file then
    file:write(content)
    file:close()
    return true
  else
    return false
  end
end

function GetSecCode(i)
--[[
НАЗВАНИЕ
    GetSecCode - функция для получения кода инструмента.

ОПИСАНИЕ
    Данная функция возвращает код инструмента для строки с заданным индексом (i) в главной таблице.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    string - Код инструмента в виде строки.
]]
	return tostring(GetCell(tt,i,3)["image"])
end

function GetPurchased(i)
--[[
НАЗВАНИЕ
    GetPurchased - функция для получения информации о покупке инструмента.

ОПИСАНИЕ
    Данная функция возвращает информацию о том, был ли инструмент в строке с заданным индексом (i) уже куплен.
    Возвращает true, если инструмент был куплен, и false в противном случае.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Информация о покупке инструмента.
]]
	local res = false
	if tonumber(GetCell(tt,i,101)["image"]) == 1 then res = true end
	return res
end

function SetPurchased(i, val)
--[[
НАЗВАНИЕ
    SetPurchased - функция для установки значения покупки инструмента.

ОПИСАНИЕ
    Данная функция устанавливает значение покупки инструмента для строки с заданным индексом (i) в главной таблице.
    Значение параметра val должно быть 1 - куплено или 0 - нет.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.
    val (number) - Значение покупки инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет.
]]
	SetCell(tt, i, 101, tostring(val))
end

function GetSold(i)
--[[
НАЗВАНИЕ
    GetSold - функция для получения информации о продаже инструмента.

ОПИСАНИЕ
    Данная функция возвращает информацию о том, был ли инструмент в строке с заданным индексом (i) уже продан.
    Возвращает true, если инструмент был продан, и false в противном случае.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Информация о продаже инструмента.
]]
	local res = false
	if tonumber(GetCell(tt,i,102)["image"]) == 1 then res = true end
	return res
end

function SetSold(i, val)
--[[
НАЗВАНИЕ
    SetSold - функция для установки значения продажи инструмента.

ОПИСАНИЕ
    Данная функция устанавливает значение продажи инструмента для строки с заданным индексом (i) в главной таблице.
    Значение параметра val должно быть 1 - продано или 0 - нет.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.
    val (number) - Значение продажи инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет.
]]
	SetCell(tt, i, 102, tostring(val))
end

function GetOn(i)
--[[
НАЗВАНИЕ
    GetOn - функция для получения состояния инструмента.

ОПИСАНИЕ
    Данная функция возвращает информацию о том, включен ли инструмент в строке с заданным индексом (i).
    Возвращает true, если инструмент включен, и false в противном случае.

ПАРАМЕТРЫ
    i (number) - индекс строки главной таблицы.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    boolean - Состояние инструмента.
]]
	local res = false
	if is_running and tostring(GetCell(tt,i,1)["image"]) == "Выключить" then res = true end
	return res
end

function TimeConvertToNumber(hh, mm, ss)
--[[
НАЗВАНИЕ
    TimeConvertToNumber - функция преобразования времени в числовое значение.

ОПИСАНИЕ
    Данная функция преобразует входные параметры, представляющие часы (hh), минуты (mm) и секунды (ss),
    в числовое значение, представляющее время в формате hhmmss.

ПАРАМЕТРЫ
    hh (number) - часы, заданные числом от 0 до 23.
    mm (number) - минуты, заданные числом от 0 до 59.
    ss (number) - секунды, заданные числом от 0 до 59.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    number - числовое значение времени, представляющее время в формате hhmmss.
]]
	if hh == nil or mm == nil or ss == nil then
		return 1
	end
	local minut = ""
	local second  = ""
	if mm < 10 then minut = "0"..tostring(mm) else minut = tostring(mm)  end
	if ss < 10 then second = "0"..tostring(ss) else second = tostring(ss)  end
	return tonumber(tostring(hh)..minut..second)
end

function getLocalTimeAsNumber() -- int
--[[
НАЗВАНИЕ
    getLocalTimeAsNumber - функция получения текущего локального времени в виде числа в формате ЧЧММСС.

ОПИСАНИЕ
    Данная функция возвращает текущее локальное время в виде числового значения,
    представляющего время в формате ЧЧММСС (часы, минуты, секунды).

ПАРАМЕТРЫ
    Нет.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    number - числовое значение времени, представляющее текущее локальное время в формате ЧЧММСС.
]]
	local hour = os.sysdate().hour
	local minute = os.sysdate().min
	local second = os.sysdate().sec

	local formatted_minute = minute < 10 and "0" .. tostring(minute) or tostring(minute)
	local formatted_second = second < 10 and "0" .. tostring(second) or tostring(second)

	return tonumber(hour .. formatted_minute .. formatted_second)
end

function getLocalHourAsNumber() -- int
--[[
НАЗВАНИЕ
    getLocalHourAsNumber - функция получения текущего локального часа.

ОПИСАНИЕ
    Данная функция возвращает текущий час на локальной машине в виде числового значения.

ПАРАМЕТРЫ
    Нет.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    number - час.
]]
	return tonumber(os.sysdate().hour)
end


-----------------------------------------------------------------------------------------------------------------

--==========================================================ЗОНА ТаблицЫ QTable=====================================================================================
-- Функция инициализации таблицы
function QTable.new()
--[[
НАЗВАНИЕ
    QTable.new - функция инициализации таблицы.

ОПИСАНИЕ
    Данная функция создает новую таблицу для вывода информации на терминал QUIK. 

ПАРАМЕТРЫ
    нет

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращает объект-таблицу или nil, если создание таблицы не удалось.

КОММЕНТАРИИ
    Функция использует функцию AllocTable() для создания таблицы и возвращает объект-таблицу для последующего использования. 

    При создании новой таблицы инициализируются следующие параметры:
        - t_id (number) - идентификатор таблицы
        - caption (string) - заголовок таблицы
        - created (boolean) - флаг, указывающий, была ли таблица успешно создана
        - curr_col (number) - индекс текущей колонки
        - columns (table) - таблица с описанием параметров столбцов

]]
    t_id = AllocTable()          -- создание новой таблицы
    if t_id ~= nil then          -- проверка успешности создания таблицы
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id        -- присваивание идентификатора таблицы
        q_table.caption = ""     -- присваивание заголовка таблицы
        q_table.created = false  -- флаг, указывающий, что таблица еще не была создана
        q_table.curr_col=0       -- установка значения текущей колонки
        -- Таблица с описанием параметров столбцов
        q_table.columns={}       -- инициализация списка столбцов
        return q_table           -- возвращение объект-таблицы
    else
        return nil  -- возвращение nil, если создание таблицы не удалось
    end
end
--Создаем и инициализируем экземпляр таблицы QTable
test_table = QTable:new()
-- Функция инициализации таблицы


function InitTable()
    tt = test_table.t_id
		AddColumn(tt, 1, "", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 2, " Код класса", true,QTABLE_STRING_TYPE,12)
		AddColumn(tt, 3, " Код бумаги", true,QTABLE_STRING_TYPE,12)
		AddColumn(tt, 4, " Бумага", true,QTABLE_STRING_TYPE,16)
		AddColumn(tt, 5, " Число лотов в позиции", true,QTABLE_INT_TYPE,25)
		
		AddColumn(tt, 6, " Цена 10:00:00", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 7, " Час проверки", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 8, " Минута проверки", true,QTABLE_INT_TYPE,18)
		AddColumn(tt, 9, " Секунда проверки", true,QTABLE_INT_TYPE,18)
		AddColumn(tt, 10, " ", true,QTABLE_STRING_TYPE,2)		
		AddColumn(tt, 11, " Процент для отложенного ордера", true,QTABLE_DOUBLE_TYPE,25) -- число с плавающеи? точкои?;
		AddColumn(tt, 18, " ", true,QTABLE_STRING_TYPE,0)
		AddColumn(tt, 101, " Куплено", true,QTABLE_INT_TYPE,0)
		AddColumn(tt, 102, " Продано", true,QTABLE_INT_TYPE,0)
		
		cols_in_main_window = 102

    CreateWindow(tt)
    -- Присваиваем окну заголовок
    SetWindowCaption(tt, script_name)
    -- Задаем позицию окна
	main_window_x_coord=66
	main_window_y_coord=111
	main_window_height=50+16+16+16
	main_window_width=1100
    SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	--Кнопки
	row = InsertRow(tt, -1)
	SetCell(tt, 1, 1, "Добавить инструмент")
	rows_in_main_window = rows_in_main_window + 1
	
	-- визуально разделяем колонки цветом
	local color_back = RGB(213,234,222)
	for i=2,99,2 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	-- цвет настраеваемых параметров
	local color_back = RGB(88,222,88)
		for i=7, 13 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	SetColor(tt, QTABLE_NO_INDEX, 6, RGB(230,230,255), RGB(0,0,0), RGB(230,230,255), RGB(0,0,0))
	SetColor(tt, QTABLE_NO_INDEX, 10, RGB(230,230,255), RGB(0,0,0), RGB(230,230,255), RGB(0,0,0))
	
    -- Подписываемся на события
    SetTableNotificationCallback(tt, OnTableEvent)
	
	-- Восстанавливаем главное окно
	if fileExists(csv_file_name) then
		restoreWindow()
	end
end

-- Функция обрабатывает события в таблице
function OnTableEvent(t_id, msg, par1, par2)
--message("msg = "..msg.."   par1 = "..par1.."   par2 = "..par2)
	clicked_row = tonumber(par1)
--   При закрытии окна
	if msg==24 then
		OnStop()
		is_stopped = true
		is_running=false
	end
	if is_running and msg==11 then
		--Подсветка ячейки
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and (msg==11 or msg==4) then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end

	if is_running and msg==11 then --Нажатие левой кнопки мыши
		--Подсветка ячейки
		Highlight(t_id,par1,par2,000255000,2,500)	
	end
	if is_running and msg==4 then -- двойное Нажатие правой кнопки мыши
		clicked_row = tonumber(par1)
		if tostring(GetCell(tt,current_row_number,3)["image"])~="" then
			InitTable_conf() --  Запускаем окно подтверждения удаления инструмента
		end
	end
	
		--При клике по "Добавить инструмент "
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tt,par1,1)["image"])=="Добавить инструмент" then
			row_new_instrument = tonumber(par1)
			InitTable_C() --  Запускаем окно с таблицей классов
			
			-- Сохранение таблицы главного окна
			saveMainWindowTableToCSV()
			
		end
		-- Включение
		if tostring(GetCell(tt,par1,1)["image"])=="Включить" and
		CheckAllCellsFilled(par1) then
		
			clicked_row = tonumber(par1)
			InitTable_task() --  Запускаем окно с таблицей действий
		else
			if tostring(GetCell(tt,par1,1)["image"])=="Включить" then
				message("Не корректные данные")
			end
		end
		-- Выключение
		if tostring(GetCell(tt,par1,1)["image"])=="Выключить" then 
			clicked_row = tonumber(par1)
			Class_Code = GetCell(tt,par1,2)["image"]
			Sec_Code = GetCell(tt,par1,3)["image"]
			SetCell(tt, clicked_row, 1, "Включить")
		end
	end
	-- Клик по названию инструмента
	if is_running and (par2==3 or par2==4) and msg==11 and tostring(GetCell(tt,par1,par2)["image"])~="" then
			clicked_row = tonumber(par1)
			InitTable_inf() --  Запускаем окно с информационной таблицей
	end
	-- Нажатия клавиш клавиатуры
	if is_running and msg==6 then
		if (current_column_number == 5    -- лоты
		or current_column_number == 7     -- часы
		or current_column_number == 8     -- минуты
		or current_column_number == 9     -- секунды
		or current_column_number == 11    -- проценты
		)
		and (current_row_number < rows_in_main_window) then
			
			SetCell(tt, current_row_number, 1, "Включить")         -- выключение работы в этой строке
			Highlight(tt,current_row_number, 1, 000255000, 2, 100) -- подсветка отключенной кнопки
			SetPurchased(current_row_number, 0)
			SetSold(current_row_number, 0)
			-- цифры
			if par2 >=48 
			and par2 <=57 
			then
				user_input = user_input..tostring(par2-48)
			end
			if current_column_number == 11 then
				-- точка
				if par2 ==46 or par2 ==44 then
					user_input = user_input.."."
				end
				
			end
			
			
			-- бэк спейс
			if par2 == 8 then
				user_input = ""
			end
			-- проверка
			if user_input ~= "" then
				if (
				current_column_number == 7
				)
				and 
				(
				tonumber(user_input) > 23
				or 
				tonumber(user_input) < 0
				) 
				then
					user_input = ""
				end
				
				if (
					current_column_number == 8
					or current_column_number == 9
					)
					and 
					(
					tonumber(user_input) > 59
					or tonumber(user_input) < 0
					) 
					then
					user_input = ""
				end
			end
			
			-- заполнение ячейки
			SetCell(tt, current_row_number, current_column_number, user_input)
			
			-- ввод
			if par2 == 13 then
				user_input = ""
				current_column_number = current_column_number + 1
				Highlight(t_id,current_row_number,current_column_number,000255000,2,100)
			end
		end
	end

end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Account_Table=====================================================================================
-- Функция инициализации таблицы
function Account_Table.new()
    a_id = AllocTable()
    if a_id ~= nil then
        a_table = {}
		setmetatable(a_table, Account_Table)
		a_table.a_id=a_id
		a_table.caption = ""
		a_table.created = false
		a_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		a_table.columns={}
		return a_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Account_Table
test_a_table = Account_Table:new()
-- Функция инициализации таблицы
function InitTable_A()
    att = test_a_table.a_id
	sleep(10)
	AddColumn(att, 1, "Счета", true,QTABLE_STRING_TYPE,25)
	AddColumn(att, 2, "Описание", true,QTABLE_STRING_TYPE,44)
    CreateWindow(att)
    -- Присваиваем окну заголовок
    SetWindowCaption(att, "Счета")
    -- Задаем позицию окна
	ox=66
	oy=66
	additional_window_height=40+16+16
	window_width=400
	vo=0
	for i2 = 0,getNumberOf("trade_accounts") - 1 do
		row = InsertRow(att, -1)
		SetCell(att, row, 1, getItem("trade_accounts",i2).trdaccid)
		vo=vo+18
		SetCell(att, row, 2, getItem("trade_accounts",i2).description)
	end;
	if vo>444 then vo=444 end
	SetWindowPos(att, ox, oy, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(att, OnTable_Event_a)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_a(a_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(a_id,par1,par2,000255000,2,500)
		-- Что нажато?
		account = tostring(GetCell(a_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 7, account)
		DestroyTable(a_id)
		test_a_table = Account_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ CLIENT_CODE_Table=====================================================================================
-- Функция инициализации таблицы
function CLIENT_CODE_Table.new()
    cc_id = AllocTable()
    if cc_id ~= nil then
       cc_table = {}
		setmetatable(cc_table, CLIENT_CODE_Table)
		cc_table.cc_id=cc_id
		cc_table.caption = ""
		cc_table.created = false
		cc_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		cc_table.columns={}
		return cc_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы CLIENT_CODE_Table
test_cc_table = CLIENT_CODE_Table:new()
-- Функция инициализации таблицы
function InitTable_CC()
    cctt = test_cc_table.cc_id
	sleep(1)
	AddColumn(cctt, 1, "Коды клиента", true,QTABLE_STRING_TYPE,25)
    CreateWindow(cctt)
    -- Присваиваем окну заголовок
    SetWindowCaption(cctt, "Коды клиента")
    -- Задаем позицию окна
	ox=111
	oy=111
	additional_window_height=40+16+16
	window_width=200
	--message('+'..class_list)
	vo=0
	for i2 = 0,getNumberOf("client_codes") - 1 do
		row = InsertRow(cctt, -1)
		SetCell(cctt, row, 1, getItem("client_codes",i2))
		vo=vo+18
	end;
	if vo>444 then vo=444 end
	SetWindowPos(cctt, ox, oy, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(cctt, OnTable_Event_cc)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_cc(cc_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(cc_id,par1,par2,000255000,2,500)
		-- Что нажато?
		client_code = tostring(GetCell(cc_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 8, client_code)
		DestroyTable(cc_id)
		test_cc_table = CLIENT_CODE_Table:new()
	end
end

--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================

--==========================================================ЗОНА ТаблицЫ Task_Table=====================================================================================
-- Функция инициализации таблицы
function Task_Table.new()
    task_id = AllocTable()
    if task_id ~= nil then
        task_table = {}
		setmetatable(task_table, Task_Table)
		task_table.task_id=task_id
		task_table.caption = ""
		task_table.created = false
		task_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		task_table.columns={}
		return task_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Task_Table
test_task_table = Task_Table:new()
-- Функция инициализации таблицы
function InitTable_task()
    tasktt = test_task_table.task_id
		sleep(1)
		AddColumn(tasktt, 1, "Действие", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 7, "Торговый счет", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 8, "Код клиента", true,QTABLE_STRING_TYPE,16)
    CreateWindow(tasktt)
    -- Присваиваем окну заголовок
    SetWindowCaption(tasktt, "Действия для "..GetCell(tt,clicked_row,4)["image"])
    -- Задаем позицию окна
	ox=0
	oy=0
	additional_window_height=40+16+16
	window_width=400
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	vo=0
	row = InsertRow(tasktt, -1)
	SetColor(tasktt, 1, 1, RGB(0, 255, 0), RGB(0, 0, 0), RGB(0, 255, 0), RGB(0, 0, 0))
	SetCell(tasktt, 1, 1, "Включить")
	SetCell(tasktt, 1, 7, account)
	SetCell(tasktt, 1, 8, client_code)

	SetWindowPos(tasktt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- Подписываемся на события
    SetTableNotificationCallback(tasktt, OnTable_Event_task)
end

-- Функция обрабатывает события в таблице
function OnTable_Event_task(task_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--is_stopped = true
		--is_running=false
	end
	if is_running and msg==11 then
		--Подсветка ячейки
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and msg==11 then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end
	if is_running and par2==7 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_A() --  Запускаем окно с таблицей аккаунта
	end
	if is_running and par2==8 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_CC() --  Запускаем окно с таблицей клиентов
	end
	--Клик по "Включить"
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tasktt,par1,1)["image"])=="Включить" then
			row_on = tonumber(par1)
			if  GetCell(tasktt,row_on,7)["image"]=="" 
			or GetCell(tasktt,row_on,8)["image"]=="" then
				message("Не все поля заполнены")
			else
					SetCell(tt, clicked_row, 1, "Выключить")
					SetCell(tt, clicked_row, 101, "0")
					SetCell(tt, clicked_row, 102, "0")
					DestroyTable(task_id)
					test_task_table = Task_Table:new()
					return
				
			end
		end
	end
	-- Нажатия клавиш клавиатуры
	if is_running and msg==6 then
		-- цифры
		if par2 >=48 and par2 <=57 then
			user_input = user_input..tostring(par2-48)
		end
		-- точка
		if par2 == 46 then
			user_input = user_input.."."
		end
		if par2 == 45 then
			user_input = user_input.."-"
		end
		-- бэк спейс
		if par2 == 8 then
			user_input = ""
		end
		SetCell(tasktt, current_row_number, current_column_number, user_input)
		-- ввод
		if par2 == 13 then
			user_input = ""
			current_column_number = current_column_number + 1
			Highlight(task_id,current_row_number,current_column_number,000255000,2,100)
		end
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ inf_Table=====================================================================================
-- Функция инициализации таблицы
function Inf_Table.new()
    inf_id = AllocTable()
    if inf_id ~= nil then
        inf_table = {}
		setmetatable(inf_table, Inf_Table)
		inf_table.inf_id=inf_id
		inf_table.caption = ""
		inf_table.created = false
		inf_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		inf_table.columns={}
		return inf_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Inf_Table
test_inf_table = Inf_Table:new()
-- Функция инициализации таблицы
function InitTable_inf()
    inftt = test_inf_table.inf_id
		sleep(1)
		AddColumn(inftt, 1, "Параметр", true,QTABLE_STRING_TYPE,25)
		AddColumn(inftt, 2, "Значение", true,QTABLE_STRING_TYPE,77)
    CreateWindow(inftt)
    -- Присваиваем окну заголовок
    SetWindowCaption(inftt, "Информация о инструменте")
    -- Задаем позицию окна
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	--message('+'..class_list)
	vo=0
	for k,v in pairs(getSecurityInfo(tostring(GetCell(tt,clicked_row,2)["image"]), tostring(GetCell(tt,clicked_row,3)["image"]))) do
		if string.len(tostring(v))>0 then
			row = InsertRow(inftt, -1)
			SetCell(inftt, row, 1, k)
			vo=vo+15
			SetCell(inftt, row, 2, tostring(v))
		end
	end
	if vo>444 then vo=444 end
	SetWindowPos(inftt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- Подписываемся на события
    SetTableNotificationCallback(inftt, OnTable_Event_inf)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_inf(inf_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(inf_id,par1,par2,000255000,2,500)
		-- Что нажато?
		DestroyTable(inf_id)
		test_inf_table = Inf_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Class_Table=====================================================================================
-- Функция инициализации таблицы
function Class_Table.new()
    c_id = AllocTable()
    if c_id ~= nil then
        c_table = {}
		setmetatable(c_table, Class_Table)
		c_table.c_id=c_id
		c_table.caption = ""
		c_table.created = false
		c_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		c_table.columns={}
		return c_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Class_Table
test_c_table = Class_Table:new()

-- Функция инициализации таблицы
function InitTable_C()
    ctt = test_c_table.c_id
	sleep(1)
	AddColumn(ctt, 1, "Код класса", true,QTABLE_STRING_TYPE,25)
	AddColumn(ctt, 2, "Название класса", true,QTABLE_STRING_TYPE,77)
    CreateWindow(ctt)
    -- Присваиваем окну заголовок
    SetWindowCaption(ctt, "Выбрать класс")
    -- Задаем позицию окна
	ox=222
	oy=222
	additional_window_height=40+17
	window_width=600
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	vo=0
	for i in string.gmatch(class_list, "[^%,]+") do
		row = InsertRow(ctt, -1)
		SetCell(ctt, row, 1, i)
		vo=vo+16
		c_name= getClassInfo(i).name
		SetCell(ctt, row, 2, c_name)
	end
	if vo>444 then vo=444 end
	SetWindowPos(ctt, ox, additional_window_height+17, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(ctt, OnTable_Event_c)
end

-- Функция обрабатывает события в таблице
function OnTable_Event_c(c_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(c_id,par1,par2,000255000,2,500)
		-- Что нажато?
		Class_Code = tostring(GetCell(c_id,par1,1)["image"])
		SetCell(tt, row_new_instrument, 2, Class_Code)
		DestroyTable(c_id)
		test_c_table = Class_Table:new()
		InitTable_S()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Sec_Table=====================================================================================
-- Функция инициализации таблицы
function Sec_Table.new()
    s_id = AllocTable()
    if s_id ~= nil then
        s_table = {}
		setmetatable(s_table, Sec_Table)
		s_table.s_id=s_id
		s_table.caption = ""
		s_table.created = false
		s_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		s_table.columns={}
		return s_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Sec_Table
test_s_table = Sec_Table:new()
-- Функция инициализации таблицы
function InitTable_S()
    stt = test_s_table.s_id
	sleep(1)
	AddColumn(stt, 1, "Код инструмента", true,QTABLE_STRING_TYPE,25)
	AddColumn(stt, 2, "Инструмент", true,QTABLE_STRING_TYPE,55)
    CreateWindow(stt)
    -- Присваиваем окну заголовок
    SetWindowCaption(stt, "Выбрать инструмент")
    -- Задаем позицию окна
	ox=55
	oy=55
	additional_window_height=40+15
	window_width=500
    SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height)
	--Кнопки
	sec_list = getClassSecurities(Class_Code)
	sec_list=string.sub(sec_list, 1, -2)
	vo=0
	for i in string.gmatch(sec_list, "[^%,]+") do
		row = InsertRow(stt, -1)
		SetCell(stt, row, 1, i)
		vo=vo+15
		s_name= getSecurityInfo(Class_Code, i).name
		--message(c_name)
		SetCell(stt, row, 2, s_name)
	end
	if vo>444 then vo=444 end
	SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(stt, OnTable_Event)
end
-- Функция обрабатывает события в таблице
function OnTable_Event(s_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(s_id,par1,par2,000255000,2,500)
		-- Что нажато?
		Sec_Code = tostring(GetCell(s_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tt, row_new_instrument, 3, Sec_Code)
		s_name= getSecurityInfo(Class_Code, Sec_Code).short_name
		SetCell(tt, row_new_instrument, 4, s_name)
		row = InsertRow(tt, -1)
		rows_in_main_window = rows_in_main_window + 1
		SetCell(tt, row, 1, "Добавить инструмент")
		SetCell(tt, row-1, 1, "Включить")
		main_window_height=main_window_height+15
		SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
		DestroyTable(s_id)
		test_s_table = Sec_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Confirmation_Table=====================================================================================
-- Функция инициализации таблицы
function Confirmation_Table.new()
    conf_id = AllocTable()
    if conf_id ~= nil then
        conf_table = {}
		setmetatable(conf_table, Confirmation_Table)
		conf_table.conf_id=conf_id
		conf_table.caption = ""
		conf_table.created = false
		conf_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		conf_table.columns={}
		return conf_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Confirmation_Table
test_Confirmation_Table = Confirmation_Table:new()

-- Функция инициализации таблицы
function InitTable_conf()
    conftt = test_Confirmation_Table.conf_id
	sleep(1)
	AddColumn(conftt, 1, " ", true,QTABLE_STRING_TYPE,11)
	AddColumn(conftt, 2, " ", true,QTABLE_STRING_TYPE,11)
    CreateWindow(conftt)
    -- Присваиваем окну заголовок
	_ = tostring(GetCell(tt,current_row_number,4)["image"])
    SetWindowCaption(conftt, "Вы хотите удалить инструмент ".._.." ?")
	_=nil
    -- Задаем позицию окна
	ox=55
	oy=55
	additional_window_height=40+15+33
	window_width=444
	row = InsertRow(conftt, -1)
	SetCell(conftt, row, 1, "ДА")
	SetCell(conftt, row, 2, "НЕТ")
    SetWindowPos(conftt, ox, additional_window_height+15, window_width, additional_window_height)
    -- Подписываемся на события
    SetTableNotificationCallback(conftt, OnTable_conf_Event)
end

-- Функция обрабатывает события в таблице
function OnTable_conf_Event(conf_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(conf_id,par1,par2,000255000,2,500)
		-- Что нажато?
		local _ = tostring(GetCell(conftt,par1,par2)["image"])
		if _ == "ДА" then
			-- процесс удаления строки
			deleteRowInMainWindow()
		end
		--message(_)
		DestroyTable(conf_id)
		test_Confirmation_Table = Confirmation_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================

function restoreWindow()
--[[
НАЗВАНИЕ
    restoreWindow - функция для восстановления главного окна.

ОПИСАНИЕ
    Данная функция считывает данные из файла CSV с помощью функции readCSV() и 
	восстанавливает таблицу в главном окне программы. 
    Затем она устанавливает новые размеры и позицию главного окна в 
	соответствии с количеством строк в таблице.

ПАРАМЕТРЫ
    нет
    
ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
	local filepath = csv_file_name
	local data = readCSV(filepath, separator)
	rows_in_main_window = 1
	if #data > 0 then
		rows_in_main_window = #data
		for i = 1, rows_in_main_window - 1 do
		
			row = InsertRow(tt, -1)
		end
	end
	main_window_height=main_window_height + 15 * (rows_in_main_window)
	SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	restoreTable(data)
end

function deleteRowInMainWindow()
--[[
НАЗВАНИЕ
    deleteRowInMainWindow - функция для удаления строки в главном окне.

ОПИСАНИЕ
    Данная функция удаляет выбранную строку из таблицы главного окна. 
	Сначала она считывает данные из файла CSV с помощью функции readCSV(),
    затем удаляет строку из таблицы данных, 
	также удаляет строку из таблицы главного окна с помощью функции DeleteRow() 
	и затем перезаписывает данные в файл CSV с помощью функции createCSV().

ПАРАМЕТРЫ
    нет
    
ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
	local filepath = csv_file_name
	local data = prepareData()
	table.remove(data, clicked_row) -- Удаляем строку
	DeleteRow(tt, clicked_row)
	--data = prepareData()
	createCSV(filepath, data, separator)
	
	main_window_height=main_window_height - 15
	SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	data = readCSV(filepath, separator)
	restoreTable(data)
	rows_in_main_window = rows_in_main_window - 1
	
	--createCSV("exsemp.csv", data, separator)
end

function createCSV(filepath, data, separator)
--[[
НАЗВАНИЕ
    createCSV - функция для создания файла CSV и записи в него данных.

ОПИСАНИЕ
    Данная функция создает файл CSV с указанным путем и записывает в него данные из
    указанной таблицы. Разделитель между значениями столбцов указывается также.

ПАРАМЕТРЫ
    filepath (string) - путь к создаваемому файлу CSV.
    data (table) - таблица с данными, которые будут записаны в файл. Первая строка таблицы
                   будет использована как заголовок файле.
    separator (string) - разделитель между значениями столбцов в файле.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
    local file = io.open(filepath, "w") -- Открываем файл для записи
    if file then
        -- Записываем данные в файл
        for _, row in ipairs(data) do
            file:write(table.concat(row, separator) .. ",\n")
        end
        file:close() -- Закрываем файл
        --message("Файл CSV создан успешно!")
    else
        message("Ошибка при создании файла CSV!")
    end
end

function readCSV(filepath, separator) -- tab
--[[
НАЗВАНИЕ
    readCSV - функция для чтения файла CSV и возвращения таблицы данных.

ОПИСАНИЕ
    Данная функция открывает файл CSV с указанным путем, читает его содержимое и возвращает
    таблицу данных. Каждая строка файла становится отдельной строкой таблицы, а значения
    столбцов разделены указанным разделителем.

ПАРАМЕТРЫ
    filepath (string) - путь к файлу CSV, который нужно прочитать.
    separator (string) - разделитель, используемый для разделения значений столбцов.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    table - таблица с данными из файла CSV. Если файл не найден или возникла ошибка во
            время чтения файла, возвращается nil.
]]
    local file = io.open(filepath, "r") -- Открываем файл для чтения
    if file then
        local data = {} -- Создаем таблицу для хранения данных
        for line in file:lines() do
            local row = {}
			for value in string.gmatch(line, "([^" .. separator .. "]*)" .. separator) do
				table.insert(row, value)
			end			
            table.insert(data, row)
        end
        file:close() -- Закрываем файл
        return data
    else
        message("Ошибка при чтении файла CSV!")
        return nil
    end
end


function prepareData() -- tab
--[[
НАЗВАНИЕ
    prepareData - функция для подготовки таблицы data.

ОПИСАНИЕ
    Данная функция создает таблицу с данными из главного окна, полученных с помощью функции GetCell значений.

ПАРАМЕТРЫ

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    table - таблица data с данными из GetCell.
]]

    local data = {}
    local cellValue = ""
    for row = 1, rows_in_main_window do
        local rowData = {}
        for col = 1, cols_in_main_window do
			local status, result = pcall(function()
				cellValue = GetCell(tt, row, col)["image"]
				
			end)
            table.insert(rowData, cellValue)
        end
        table.insert(data, rowData)
    end
    return data
end

function restoreTable(data)
--[[
НАЗВАНИЕ
    restoreTable - функция для восстановления таблицы рабочего окна из данных.

ОПИСАНИЕ
    Данная функция восстанавливает таблицу рабочего окна из данных, содержащихся в таблице data.
    Каждое значение из таблицы data будет записано в ячейку таблицы рабочего окна с помощью функции SetCell.

ПАРАМЕТРЫ
    data (table) - таблица с данными для восстановления таблицы рабочего окна.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
    for row = 1, rows_in_main_window do
        for col = 1, cols_in_main_window do
			local status, result = pcall(function()
				SetCell(tt, row, col, data[row][col])
			end)
        end
    end
end

function saveMainWindowTableToCSV()
--[[
НАЗВАНИЕ
    saveMainWindowTableToCSV - функция для сохранения таблицы главного окна в CSV-файл.

ОПИСАНИЕ
    Данная функция сохраняет таблицу главного окна в формате CSV. Для этого она сначала подготавливает таблицу data с помощью функции prepareData(), 
    а затем создает CSV-файл с помощью функции createCSV(). 
    
ПАРАМЕТРЫ
    нет
    
ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
	-- Сохранение таблицы главного окна
	local filepath = csv_file_name
	local data = prepareData()
	createCSV(filepath, data, separator)
end

function tableEqual(table1, table2) -- bool
--[[
НАЗВАНИЕ
    tableEqual - функция для сравнения двух таблиц.

ОПИСАНИЕ
    Данная функция сравнивает две таблицы table1 и table2 на равенство. Она рекурсивно проверяет каждую пару ключ-значение в таблицах и возвращает
    true, если все элементы в таблицах идентичны, и false в противном случае.

ПАРАМЕТРЫ
    table1 (table) - первая таблица для сравнения.
    table2 (table) - вторая таблица для сравнения.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    (boolean) - результат сравнения таблиц: true, если таблицы равны, и false в противном случае.
]]

    if table1 == table2 then
        return true
    end

    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end

    for key, value in pairs(table1) do
        if not tableEqual(value, table2[key]) then
            return false
        end
    end

    for key, _ in pairs(table2) do
        if table1[key] == nil then
            return false
        end
    end

    return true
end

function position_size(class, sec) -- int
--[[
НАЗВАНИЕ
  position - Определение числа лотов в позиции

ОПИСАНИЕ
  функция определяет количество лотов в открытой позиции по инструменту.

ПАРАМЕТРЫ
  Отсутствуют.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
  количество лотов в открытой позиции (целое число).
]]--
	local open_lots = 0
	for i = 0,getNumberOf("depo_limits") - 1 do
		-- если строка по нужному инструменту не равна нулю то
		if getItem("depo_limits",i).sec_code == sec and getItem("depo_limits",i).limit_kind == 2 then
			-- если текуща позиция > 0, то открыта длинная позиция (BUY)
			if getItem("depo_limits",i).currentbal > 0 then 
				BuyVol = getItem("depo_limits",i).currentbal	-- количество лотов в позиции BUY
				open_lots = BuyVol
			else   -- иначе открыта коротка¤ позици¤ (SELL)
				SellVol = math.modf(getItem("depo_limits",i).currentbal) -- количество лотов в позиции SELL
				open_lots = SellVol
			end;
		end;
	end;	
	local n,m = math.modf(tonumber(open_lots))
	return tonumber(n)
end

function OpenPrice(class, sec)
--[[
НАЗВАНИЕ
    OpenPrice - получение цены открытия для инструмента
ОПИСАНИЕ
    Данная функция подключает график для указанного инструмента, 
	получает данные с сервера и возвращает цену открытия. 
	Если график не открыт или возникла ошибка подключения, функция выводит сообщение об ошибке.
ПАРАМЕТРЫ
    class (string) - класс инструмента
	sec (string) - код инструмента
ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    (number) - цена открытия
]]
	local hour = getLocalHourAsNumber()
	-- Подключаем график
	ds, Error = CreateDataSource(class, sec, 60)
	-- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) end
	local Size = ds:Size() -- Возвращает текущий размер (количество свечей в источнике данных)
	
	local bar_time = {}
	local bar_hour = 0
	for i = 0, (hour + 2) do
		bar_time = ds:T(Size-i)
		bar_hour = tonumber(bar_time.hour)
		O = ds:O(Size-i)
		
		if bar_hour == 10 then
			ds:Close() -- Удаляет источник данных, отписывается от получения данных
			-- message(tostring(O))
			return tonumber(tostring(O))
		end
	end
	ds:Close() -- Удаляет источник данных, отписывается от получения данных
end