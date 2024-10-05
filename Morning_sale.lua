--[[
��������
    Morning_sale_V132

��������
    ������ ������ ������������ �� ���� ��������� ������ �� ��������� QUIK
	
	�����, � ������ �������� ����� 10.00:
	1. ��������� ���� ���� � 10.00.10 (����� ������������ � ����������) �� ��������  ��������, 
		��������� � ����� ���� � ������ �������� ����� � 10.00.00:
	1. ���� ������� ���� ���� ���� ���� ���� � 10.00.00, �� ����� ��������� 
	2. ���� ���� ���� ���� ���� ���� �  10.00.00, �� 
	   ���������� ���������� ����� ���������� �� ������� +36% �� ������� ���� ���� �� �������� 
	   (������� ������� � ���������� ��� ������ �������)
	3. ��� ������������� ������� �� �������� �� ����� �������� ��� ����� ��������� � �� ���� �� ����������� � ������ 1 .
	
	��������� � ��������, ���������� ������ ������, �������� ��������������. 
	
	� ������ 1.3.2 ��������� ����������� ����� �������� �������� ��� ������� "������� ��� ����������� ������".  
	� ������ 1.3.3 ������� �������� ����������� ���� ��������. 
������
    1.3.3

�����������
    ������ ������ (https://t.me/ruslan_mashkin )

���� ��������
    27.09.2023
]]--



------------------------------------------------- �������������� ���������� ���������� --------------------------
local account = ""                         -- �������� ����
local client_code = ""                     -- ��� �������
local script_name = "Morning_sale_V1"      -- �������� �������
local is_running = true                    -- ����, ����������� �������� �� ������
local is_stopped = false                   -- ����, ����������� ���������� �� ������
local row_new_instrument = 0               -- ����� ������ � �������, ��� ����� ����������
local clicked_row = 0                      -- ����� ������ � ������� �������, ��� ��� ����
local clicked_another_row = 0              -- ����� ������ � ������ ��������, ��� ��� ����
local additional_window_height = 0         -- ������ �������������� ����
local main_window_height = 0               -- ������ �������� ����
local main_window_width = 0                -- ������ �������� ����
local main_window_x_coord = 0              -- X-���������� �������� ����
local main_window_y_coord = 0              -- Y-���������� �������� ����
local rows_in_main_window = 0              -- ���������� ����� �������� ����
local cols_in_main_window = 0              -- ���������� ������� �������� ����
local current_row_number = 0               -- ������� ����� ������ � �������
local current_column_number = 0            -- ������� ����� ������� � ������� 
local user_input = ""                      -- ������ ����� ������������
local native_folder_path = ""              -- ���� � �����
local current_second = 0                   -- ��� ����������� ������� � ��������� �������
local Class_Code = ""                      -- ����� ���������� �����������
local Sec_Code = ""                        -- ��� ���������� �����������
local g_lots = 1                           -- ���������� ��������� ���

local timeRange = 3                        -- ��������� �������� � ������� ����� ��������� ������ (���)
local start_work_time = 100000             -- ����� ������ �������� ������ � ������� ������
local finish_work_time = 183959            -- ����� ��������� �������� ������ � ������� ������
local check_time = 100000                  -- ����� ����� ����� � ������� ����������� ���� ��� �������� ��������� 


local csv_file_name = script_name.."_main_window.csv"  -- ��� ����� ��� ���������� ������� ����
local separator = ","                      -- ����������� � csv

-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- �������������� ������� ������� --------------------------------

-- ������� �������� �������
QTable = {}
QTable.__index = QTable

-- ������� ������� �������
Class_Table = {}
Class_Table.__index = Class_Table

-- ������� ������� ������������
Sec_Table = {}
Sec_Table.__index = Sec_Table

-- ������� ������� ����������
Inf_Table = {}
Inf_Table.__index = Inf_Table

-- ������� ������� ��������
Task_Table = {}
Task_Table.__index = Task_Table

-- ������� ������� ��������� �����
Account_Table = {}
Account_Table.__index = Account_Table

-- ������� ������� ���� �������
CLIENT_CODE_Table = {}
CLIENT_CODE_Table.__index = CLIENT_CODE_Table

-- ������� ������� �������������
Confirmation_Table = {}
Confirmation_Table.__index = Confirmation_Table

-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- ������� ������� -----------------------------------------------

function OnStop()
--[[
��������
    ���������� ������� OnStop()

��������
    ������ ���������� ���������� ��� ��������� ��������� ������ �� ��������� QUIK.
	� ������� ���������� �������� ���� ��������� ������ � ��������� ����� is_stopped � true.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]--
    -- ������������� ���� ��������� �������
    is_stopped = true
    
    -- ������������� ���� ������ ������� ��� false
    is_running = false
	
    -- ������� ��������� �������
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
��������: OnInit

��������:
    ������ ������� ���������� ��� ������� ��������� ������ �� ��������� QUIK.

���������:
    p_ - ������. ���� � �����, � ������� �������� ������.

������������ ��������:
    ��� ������������ ��������.
]]--

	native_folder_path = tostring(p_)
end

function main()
--[[
��������
    ������� ������� ������� - main()

��������
    ������ ������� ��������� ������� ���� � ��������.
    ����� ������� �������� ��������� �������� ��� �������, ������� ����������� � ����������� �����. 
    ���� ���� is_stopped ���������� � true, �� ������� ��������� ������, ��� ���������������.
    ����� ������� �������� ������� Table_UpDate(), ������� ��������� ������ � ������� � ��������� ����������� ��������.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������
]]--
	InitTable()                                   -- ��������� ���� � ��������
	sleep(10) 
	local sr=SetSelectedRow(t_id, 1)              -- ��������� ����� �� ������ ������
	while is_running do                           -- ����������� ����
		if is_stopped then                        -- ���� ���� ��������� ����������, �� ������� �� �����
			return
		end
		sleep(5)                                  -- ��������
		Table_UpDate()                            -- ��������� ������ � �������
		d1, d2 = {}, {}                           -- ������� ��� ������ � ������� �������� ����
		d1 = prepareData()                        -- ������� ��������� �������� ����
		d2 = readCSV(csv_file_name, separator)    -- ����������� ��������� �������� ����
		if tableEqual(d1, d2) then                -- ��������� ������
			--message("������� �����")
		else
			--message("������� �� �����")
			if is_running then
				saveMainWindowTableToCSV()        -- ���� � ������� ���� �������� ��������� �� �����������
			end
		end

	end  --while
end  --function

function To_integer(n)
--[[
��������
    ������� �������������� ������ ����� � ����� ����� - To_integer()

��������
    ������ ������� �������� �� ���� ����� ����� � ����������� ��� � ����� �����. 
    ���� �������������� �� �������, �� ������� ���������� �������� nil.

���������
    ��������� �������:
    * n - ����� ����� , ������� ����� ������������� � ����� �����.

������������ ��������
    ������������ ��������:
    * ����� �����, ���� �������������� �������, ��� nil, ���� �� �������.
]]--
	return math.tointeger(tonumber(n))
end

function UpdateWindowTitle()
--[[
��������
    ������� ���������� ��������� ���� - UpdateWindowTitle()

��������
    ������ ������� ��������� ��������� �������� ����, �������� � ���� ������� ����� � ������� ����:������:�������.
	��� ����� � ��� ����� ��� ��������� ������ ������� 
���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]--
	if current_second ~= tonumber(os.date("%S")) then                           -- ���������, ���������� �� ������� �������
		current_second = tonumber(os.date("%S"))                                -- ���� ����������, �� ��������� �������� ����������
		SetWindowCaption(tt, script_name.."         "..tostring(os.date("%X"))) -- ��������� ��������� ����
	end
end


function isValidPositiveNumber(n)
--[[
��������
    ������� �������� ������������ �������� ���������� - isValidPositiveNumber()
	
��������
    ������ ������� ��������� ������������ ����������� �������� ����������.
	
���������
    ��������� �������:
    * n - ����������� �������� ����������.

������������ ��������
    * ���������� true, ���� ���������� �������� ��������� (����� �� ������ 0), ����� - false.
]]  
	local res = false                                           -- ������������� �������� ���������� � ����
	if n == nil or type(n) == "string" or n == "" or n <0 then  -- ��������� �������� �� nil, ��� "string", ������ ������ � �������������/������� �����
		res = false                                             -- ���� �������� �� ������������� �����������, �� ������������� ��������� � ����
	else
		res = true                                              -- ����� ������������� ��������� � ������
	end
	return res                                                  -- ���������� ��������� ���������� �������
end



function Last_price(class, sec)
--[[
��������
    Last_price - ������� ��������� ������� ���� ��������� �����������.

��������
    ������ ������� ���������� ������� ���� ��������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    �����, ������� ���� ��������� �����������.
]]
	return tonumber(getParamEx(class, sec, "LAST").param_value)
end

function Lot_size(class, sec)
--[[
��������
    Lot_size - ������� ��������� ���������� ����� � ���� �����������.

��������
    ������ ������� ���������� ���������� ����� � ���� ��������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    ����� �����, ���������� ����� � ���� ��������� �����������.
]]
    return tonumber(getParamEx(class, sec, "LOTSIZE").param_value)
end



function Min_price_step(class, sec)
--[[
��������
    Min_price_step - ������� ��������� ������������ ���� ���� ��� ���������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    �����, ����������� ��� ���� ��� ����������� �����������.
]]
	return tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- ����������� ��� ����

end




function CheckAllCellsFilled(i)
--[[
��������
    CheckAllCellsFilled - ������� �������� ���������� ���� ����� � ������ �������.

��������
    ������ ������� ��������� ���������� ���� ����� � ���������� ������ �������.

���������
    i (number) - ����� ������ � �������.

������������ ��������
    true, ���� ��� ������ ��������� ���������, ����� - false.
]]
	-- ������������� ���������� ��� �������� ���������� ��������.
	local res = false

	-- ��������� �������� �� ����� �������.
	local a = tonumber(GetCell(tt, i, 7)["image"])   
	local b = tonumber(GetCell(tt, i, 8)["image"])           
	local c = tonumber(GetCell(tt, i, 9)["image"])
	local d = tonumber(GetCell(tt, i, 11)["image"]) 
	-- local e = tonumber(GetCell(tt, i, 12)["image"])
	-- local f = tonumber(GetCell(tt, i, 13)["image"])
	-- local l = tonumber(GetCell(tt, i, 5)["image"])
	-- local time_today = getBuysTimeAsNumber(i)
	-- local time_tomorrow = getSellsTimeAsNumber(i)

	-- �������� ������������ ���������� �����, ����� ������� isValidPositiveNumber ��� ������ �� ���.
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
  
	-- ������� �������� ���������� ��������.
	return res
end

function MarketBuy(class, sec, number_lots)
--[[
��������
    MarketBuy - ������� �������� ������� ����� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- ��� ������
		SECCODE = sec,      		            -- ��� �����������	
		ACCOUNT = account,   			        -- ��� �����
		TYPE = "M",        		                -- ��� ('L' - ��������������, 'M' - ��������)
		TRANS_ID = tostring(os.time()),         -- ����� ����������
		OPERATION = "B",         			    -- �������� ('B' - buy, ��� 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- ����������
		PRICE = "0",                            -- ����
		ACTION = "NEW_ORDER"                    -- ��� ���������� ('NEW_ORDER' - ����� ������)
	}
	local res = sendTransaction(trans_params)   -- �������� ����������
	if is_running and string.len(res) ~= 0 then -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 
end

function MarketSell(class, sec, number_lots)
--[[
��������
    MarketSell - ������� �������� ������� ����� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- ��� ������
		SECCODE = sec,      		            -- ��� �����������	
		ACCOUNT = account,   			        -- ��� �����
		TYPE = "M",        		                -- ��� ('L' - ��������������, 'M' - ��������)
		TRANS_ID = tostring(os.time()),         -- ����� ����������
		OPERATION = "S",         			    -- �������� ('B' - buy, ��� 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- ����������
		PRICE = "0",                            -- ����
		ACTION = "NEW_ORDER"                    -- ��� ���������� ('NEW_ORDER' - ����� ������)
	}
	local res = sendTransaction(trans_params)   -- �������� ����������
	if is_running and string.len(res) ~= 0 then -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 

end


function DelayedOrderSell(class, sec, number_lots, price)
--[[
��������
    Delayed_Order - ������� ����������� ����������� ������ ���� ����-������.

��������
    ������ ������� ������������ ����������� ����������� ������ ���� ����-������ ����� �������� ���������� �� �����.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����
    price (number) - ���� ����-�������

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.


]]
	local trans_params =
		{
		["ACTION"]              = "NEW_STOP_ORDER",         -- ��� ������
		["TRANS_ID"]            = tostring(os.time()),      -- ����� ����������
		["CLASSCODE"]           = class,
		["SECCODE"]             = sec,
		["ACCOUNT"]             = account,
		["OPERATION"]           = "S",                      -- �������� ("B" - �������(BUY), "S" - �������(SELL))
		["QUANTITY"]            = tostring(number_lots),    -- ���������� � �����
		["PRICE"]               = tostring(0),              -- ����, �� ������� ���������� ������ ��� ������������ ����-����� (��� �������� ������ �� ������ ������ ���� 0)
		["STOPPRICE"]           = tostring(price),          -- ���� ����-�������
		["STOP_ORDER_KIND"]     = "TAKE_PROFIT_STOP_ORDER", -- ��� ����-������
		["EXPIRY_DATE"]         = "TODAY",                  -- ���� �������� ����-������ ("GTC" � �� ������,"TODAY" - �� ��������� ������� �������� ������, ���� � ������� "������")
		["OFFSET"]              = tostring(0),
		["OFFSET_UNITS"]        = "PERCENTS",               -- ������� ��������� ������� ("PRICE_UNITS" - ��� ����, ��� "PERCENTS" - ��������)
		["SPREAD"]              = tostring(0),
		["SPREAD_UNITS"]        = "PERCENTS",               -- ������� ��������� ��������� ������ ("PRICE_UNITS" - ��� ����, ��� "PERCENTS" - ��������)
      -- "MARKET_TAKE_PROFIT" = ("YES", ��� "NO") ������ �� ���������� ������ �� �������� ���� ��� ������������ ����-�������.
      -- ��� ����� FORTS �������� ������, ��� �������, ���������,
      -- ��� �������������� ������ �� FORTS ����� ��������� �������� ������ ����, ����� ��� ��������� ����� ��, ��� ��������
	    --["MARKET_TAKE_PROFIT"]  = "YES",
		["STOPPRICE2"]          = tostring(0),              -- ���� ����-����� 
		["IS_ACTIVE_IN_TIME"]   = "NO",
		["CLIENT_CODE"]         = tostring(client_code)
		}
	local res = sendTransaction(trans_params)
	if is_running and string.len(res) ~= 0 then           -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 
end


function Delete_Delayed_Order(class, sec)
--[[

��������
    Delete_Delayed_Order - ������� �������� ���������� ������.

��������
    ������ ������� ������������ �������� ���������� ������ �� ������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������

������������ ��������
    true - ���� ���������� ���� ���������
    false - ���� ���������� �� ���� ���������

]]
	for i = 0,getNumberOf("stop_orders") - 1 do                     -- ������������ ��� ���������� ������ �� ������, ������� ��������� � ������� "stop_orders"
		if getItem("stop_orders",i).sec_code == sec then            -- ���� ������ �� ������� ����������� �� ����� ����
			order=getItem("stop_orders",i).flags
			if bit.band(order,1)>0 then                             -- ���� ���������� ������ - ��� ����-������ ���� "����-������" (������� ����� � ������� 1)
				order_num = getItem("stop_orders",i).order_num      -- ��������� ������ ������
				local trans_params =                                -- �������� ������� ���������� ����������
					{
					["ACTION"] = "KILL_STOP_ORDER",                 -- �������� - �������� ���������� ������
					["TRANS_ID"] = tostring(os.time()),             -- ���������� ������������� ����������
					["CLASSCODE"] = class,                          -- ��� ������ �����������
					["SECCODE"] = sec,                              -- ��� �����������
					["ACCOUNT"] = account,                          -- ����� �����
					["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER", -- ��� ����-������ (����-������)
					["CLIENT_CODE"] = tostring(client_code),        -- ��� �������
					['STOP_ORDER_KEY'] = tostring(order_num)        -- ����� ��������� ������
					}
				local res = sendTransaction(trans_params)           -- ����������� ���������� �� �������� ���������� ������
				if is_running and string.len(res) ~= 0 then         -- ���� ���������� �� ���������
					message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
					return false -- ������������ false
				else -- �����
					return true -- ������������ true
				end 
			end
		end
	end  
end
 
function getSellsTimeAsNumber(i)
--[[
��������
    getSellsTimeAsNumber - ������� ��������� ������� ������� �� ����� �������.

��������
    ������ ������� ��������� ���������� � ������� ������� �� ����� ������� � ����������� �� � �������� ��������.

���������
    i (number) - ����� ������ � �������.

������������ ��������
    �������� �������� ������� ������� � ������� "HHMMSS".
]]
	local hh = tonumber(GetCell(tt, i, 7)["image"]) 
	local mm = tonumber(GetCell(tt, i, 8)["image"])
	local ss = tonumber(GetCell(tt, i, 9)["image"])
	return tonumber(TimeConvertToNumber(tonumber(hh), tonumber(mm), tonumber(ss)))
end

function Table_UpDate()
--[[
��������
    Table_UpDate - ������� ���������� ������ � ������� �������.

��������
    ������ ������� ��������� ������ � ������� ������� � ��������� �������� �������� ������.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]  
	UpdateWindowTitle()                      -- ��������� ��������� �������� ����
	
  
	for i = 1, rows_in_main_window - 1 do    -- ������� ����� ������� �������
		
		-- ���� ������ � ������������
		if is_running and tostring(GetCell(tt,i,3)["image"])~="" then
			-- ������ ����� ����������� � ����������� ���������� ���� ��������� ����� ������ ���������
		  
			local classcod = tostring(GetCell(tt,i,2)["image"])                        -- ����� ����������� �� �������
			local seccod = tostring(GetCell(tt,i,3)["image"])                          -- ��� ����������� �� �������
			SetCell(tt, i, 5, tostring(To_integer(getLots(classcod, seccod, i))))      -- ������� �� �����������
			SetCell(tt, i, 6, tostring(OpenPrice(classcod, seccod)))                   -- ���� ��� ��������
			
			----------------------------------------  �������� ������  --------------------------------------------------
			
			if GetOn(i) then                                                                   -- ���� ������ "��������" ������
				if CheckAllCellsFilled(i) then                                                 -- ���� ��� ������������� ��������� ���������
			
					LocalTimeAsNumber = getLocalTimeAsNumber()
					if LocalTimeAsNumber >= start_work_time then                               -- ���� ������� �����
						local lots = getLots(classcod, seccod, i) or 0                         -- ����� ����� � �������
						if lots > 0 then                                                       -- ���� ������� ����������
							if (LocalTimeAsNumber >= getSellsTimeAsNumber(i)) and
							(LocalTimeAsNumber <= (getSellsTimeAsNumber(i) + timeRange)) then  -- ���� ����� �������
								if GetSold(i) == false then                                    -- ���� ��� �� ��������� ����
									if IsHigherThanOpenPrice(classcod, seccod) then            -- ���� ���� ���� ���� ��������
										local price = DelayedSellPrice(classcod, seccod, i)
										DelayedOrderSell(classcod, seccod, lots, price)        -- �� ���������� �������
										SetSold(i, 1)                                          -- ������������� �������
									else
										MarketSell(classcod, seccod, lots)                     -- ����� ������� �� �����
										SetSold(i, 1)                                          -- ������������� �������
									end
								end
							else
								if                                                             -- ����
								(LocalTimeAsNumber >= finish_work_time)                        -- ������� ����� ���������
								and                                                            -- �
								(GetSold(i) == true)                                           -- ���������� ���� �������
								then                                                           -- ��
									Delete_Delayed_Order(classcod, seccod)                     -- ������ ������
									SetSold(i, 0)                                              -- ������������� ������ �������
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
��������
	IsCurrentPriceHigherThan10AM - ������� ��������� ������� ���� � ����� � 10:00:00.

��������
    ������ ������� ���������� ������� ���� � ����� �������� � ���������� �������� true, ���� ������� ���� ����.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    true, ���� ������� ���� ���� ���� � 10:00:00, ����� false (boolean).
]]  
	local currentPrice = Last_price(class, sec)         -- �������� ������� ����
	local price10AM = OpenPrice(class, sec)             -- �������� ���� ��������
	if currentPrice == nil or price10AM == nil then
		return false
	end
	return currentPrice > (price10AM - minPriceStep(class, sec))
end

function CorrectPrice(class, sec, price)
  --[[
  ��������
    CorrectPrice - ������� ������������� ��������� ���� � ����, ������������ ��������.

  ��������
    ������ ������� ������������ ��������� ���� (price) � ����, ������������ ��������.
  
  ���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.
    price (number) - ��������� ����.

  ������������ ��������
    ���������������� ���� (number).
  ]]--
  	local min_step_price = minPriceStep(class, sec)
	local res = math.floor(price / min_step_price) * min_step_price
	return math.abs(tonumber(res))
end

function minPriceStep(class, sec)
--[[
��������
	minPriceStep - ������� ��������� ������������ ���� ���� ��� �����������.

��������
	������ ������� ���������� ����������� ��� ���� ��� ���������� �����������.

���������
	class (string) - ��� ������ �����������.
	sec (string) - ��� �����������.

������������ ��������
	����������� ��� ���� (number).
]]--
	return tonumber(getParamEx(class, sec, "SEC_PRICE_STEP").param_value) -- ����������� ��� ����
end

function DelayedSellPrice(class, sec, i)
--[[
��������
	DelayedSellPrice - ������� ������� ���������� ���� �������.

��������
	������ ������� ������������ ���������� ���� ������� �� ������  ���� �������� � ���������� ��������.

���������
	class (string) - ��� ������ �����������.
	sec (string)   - ��� �����������.
	i (number) - ������ ������ ������� �������.

������������ ��������
	���������� ���� ������� (number)
]] 
	local open_price = tonumber(GetCell(tt, i, 6)["image"])
	local percent = tonumber(GetCell(tt, i, 11)["image"])
	local price = open_price + (open_price / 100 * percent)
	return CorrectPrice(class, sec, price)
end

function getLots(class, sec, i)
--[[
��������
	������� getLots - �������� ����� ����� ��� ���������� �����������.
��������
	������ ������� �������� ���������� ����� ��� ��������� �����������, 
	��������� ����� ����� � ���� � ����� ����� � �������. 
	
���������
    class (string) - ��� ������ �����������.
    sec (string)   - ��� �����������.
    i (number)     - ������ ������ ������� �������.

������������ ��������
	���������� ����� (number)
]]

	local lotSize = Lot_size(class, sec)
	local positionSize = tonumber(position_size(class, sec))
	return To_integer(positionSize / lotSize)
end

function fileExists(filename)
--[[
��������
    fileExists - ������� ��� �������� ������������� �����.

��������
    ������ ������� ���������, ���������� �� ���� � ��������� ������.

���������
    filename (string) - ��� �����, ��� �������� ����� ��������� �������������.

������������ ��������
    boolean - ���������� true, ���� ���� ����������, � false � ��������� ������.
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
��������
    createFile - ������� ��� �������� �����.

��������
    ������ ������� ������� ���� � ��������� ������.

���������
    filename (string) - ��� �����, ������� ����� �������.

������������ ��������
    boolean - ���������� true, ���� ���� ������� ������, � false � ��������� ������.
]]
	local file = io.open(filename, "w")
	if file then
		writeFile(filename, content)
		file:close()
		return true
	else
		message("������ ��� �������� �����")
		return false
	end
end

function readFile(filename)
--[[
��������
    readFile - ������� ��� ������ ����������� �����.

��������
    ������ ������� ��������� ���������� ����� � ��������� ������.

���������
    filename (string) - ��� �����, ���������� �������� ����� �������.

������������ ��������
    string - ���������� ����� � ���� ������. ���� ���� �� ������, ������������ nil.
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
��������
    writeFile - ������� ��� ������ ����������� � ����.

��������
    ������ ������� ���������� ��������� ���������� � ���� � ��������� ������.
    ���� ���� �� ����������, �� ����� ������.

���������
    filename (string) - ��� �����, � ������� ����� �������� ����������.
    content (string) - ����������, ������� ����� �������� � ����.

������������ ��������
    boolean - true, ���� ������ � ���� ������ �������, false - � ��������� ������.
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
��������
    GetSecCode - ������� ��� ��������� ���� �����������.

��������
    ������ ������� ���������� ��� ����������� ��� ������ � �������� �������� (i) � ������� �������.

���������
    i (number) - ������ ������ ������� �������.

������������ ��������
    string - ��� ����������� � ���� ������.
]]
	return tostring(GetCell(tt,i,3)["image"])
end

function GetPurchased(i)
--[[
��������
    GetPurchased - ������� ��� ��������� ���������� � ������� �����������.

��������
    ������ ������� ���������� ���������� � ���, ��� �� ���������� � ������ � �������� �������� (i) ��� ������.
    ���������� true, ���� ���������� ��� ������, � false � ��������� ������.

���������
    i (number) - ������ ������ ������� �������.

������������ ��������
    boolean - ���������� � ������� �����������.
]]
	local res = false
	if tonumber(GetCell(tt,i,101)["image"]) == 1 then res = true end
	return res
end

function SetPurchased(i, val)
--[[
��������
    SetPurchased - ������� ��� ��������� �������� ������� �����������.

��������
    ������ ������� ������������� �������� ������� ����������� ��� ������ � �������� �������� (i) � ������� �������.
    �������� ��������� val ������ ���� 1 - ������� ��� 0 - ���.

���������
    i (number) - ������ ������ ������� �������.
    val (number) - �������� ������� �����������.

������������ ��������
    ���.
]]
	SetCell(tt, i, 101, tostring(val))
end

function GetSold(i)
--[[
��������
    GetSold - ������� ��� ��������� ���������� � ������� �����������.

��������
    ������ ������� ���������� ���������� � ���, ��� �� ���������� � ������ � �������� �������� (i) ��� ������.
    ���������� true, ���� ���������� ��� ������, � false � ��������� ������.

���������
    i (number) - ������ ������ ������� �������.

������������ ��������
    boolean - ���������� � ������� �����������.
]]
	local res = false
	if tonumber(GetCell(tt,i,102)["image"]) == 1 then res = true end
	return res
end

function SetSold(i, val)
--[[
��������
    SetSold - ������� ��� ��������� �������� ������� �����������.

��������
    ������ ������� ������������� �������� ������� ����������� ��� ������ � �������� �������� (i) � ������� �������.
    �������� ��������� val ������ ���� 1 - ������� ��� 0 - ���.

���������
    i (number) - ������ ������ ������� �������.
    val (number) - �������� ������� �����������.

������������ ��������
    ���.
]]
	SetCell(tt, i, 102, tostring(val))
end

function GetOn(i)
--[[
��������
    GetOn - ������� ��� ��������� ��������� �����������.

��������
    ������ ������� ���������� ���������� � ���, ������� �� ���������� � ������ � �������� �������� (i).
    ���������� true, ���� ���������� �������, � false � ��������� ������.

���������
    i (number) - ������ ������ ������� �������.

������������ ��������
    boolean - ��������� �����������.
]]
	local res = false
	if is_running and tostring(GetCell(tt,i,1)["image"]) == "���������" then res = true end
	return res
end

function TimeConvertToNumber(hh, mm, ss)
--[[
��������
    TimeConvertToNumber - ������� �������������� ������� � �������� ��������.

��������
    ������ ������� ����������� ������� ���������, �������������� ���� (hh), ������ (mm) � ������� (ss),
    � �������� ��������, �������������� ����� � ������� hhmmss.

���������
    hh (number) - ����, �������� ������ �� 0 �� 23.
    mm (number) - ������, �������� ������ �� 0 �� 59.
    ss (number) - �������, �������� ������ �� 0 �� 59.

������������ ��������
    number - �������� �������� �������, �������������� ����� � ������� hhmmss.
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
��������
    getLocalTimeAsNumber - ������� ��������� �������� ���������� ������� � ���� ����� � ������� ������.

��������
    ������ ������� ���������� ������� ��������� ����� � ���� ��������� ��������,
    ��������������� ����� � ������� ������ (����, ������, �������).

���������
    ���.

������������ ��������
    number - �������� �������� �������, �������������� ������� ��������� ����� � ������� ������.
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
��������
    getLocalHourAsNumber - ������� ��������� �������� ���������� ����.

��������
    ������ ������� ���������� ������� ��� �� ��������� ������ � ���� ��������� ��������.

���������
    ���.

������������ ��������
    number - ���.
]]
	return tonumber(os.sysdate().hour)
end


-----------------------------------------------------------------------------------------------------------------

--==========================================================���� ������� QTable=====================================================================================
-- ������� ������������� �������
function QTable.new()
--[[
��������
    QTable.new - ������� ������������� �������.

��������
    ������ ������� ������� ����� ������� ��� ������ ���������� �� �������� QUIK. 

���������
    ���

������������ ��������
    ���������� ������-������� ��� nil, ���� �������� ������� �� �������.

�����������
    ������� ���������� ������� AllocTable() ��� �������� ������� � ���������� ������-������� ��� ������������ �������������. 

    ��� �������� ����� ������� ���������������� ��������� ���������:
        - t_id (number) - ������������� �������
        - caption (string) - ��������� �������
        - created (boolean) - ����, �����������, ���� �� ������� ������� �������
        - curr_col (number) - ������ ������� �������
        - columns (table) - ������� � ��������� ���������� ��������

]]
    t_id = AllocTable()          -- �������� ����� �������
    if t_id ~= nil then          -- �������� ���������� �������� �������
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id        -- ������������ �������������� �������
        q_table.caption = ""     -- ������������ ��������� �������
        q_table.created = false  -- ����, �����������, ��� ������� ��� �� ���� �������
        q_table.curr_col=0       -- ��������� �������� ������� �������
        -- ������� � ��������� ���������� ��������
        q_table.columns={}       -- ������������� ������ ��������
        return q_table           -- ����������� ������-�������
    else
        return nil  -- ����������� nil, ���� �������� ������� �� �������
    end
end
--������� � �������������� ��������� ������� QTable
test_table = QTable:new()
-- ������� ������������� �������


function InitTable()
    tt = test_table.t_id
		AddColumn(tt, 1, "", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 2, " ��� ������", true,QTABLE_STRING_TYPE,12)
		AddColumn(tt, 3, " ��� ������", true,QTABLE_STRING_TYPE,12)
		AddColumn(tt, 4, " ������", true,QTABLE_STRING_TYPE,16)
		AddColumn(tt, 5, " ����� ����� � �������", true,QTABLE_INT_TYPE,25)
		
		AddColumn(tt, 6, " ���� 10:00:00", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 7, " ��� ��������", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 8, " ������ ��������", true,QTABLE_INT_TYPE,18)
		AddColumn(tt, 9, " ������� ��������", true,QTABLE_INT_TYPE,18)
		AddColumn(tt, 10, " ", true,QTABLE_STRING_TYPE,2)		
		AddColumn(tt, 11, " ������� ��� ����������� ������", true,QTABLE_DOUBLE_TYPE,25) -- ����� � ���������? ������?;
		AddColumn(tt, 18, " ", true,QTABLE_STRING_TYPE,0)
		AddColumn(tt, 101, " �������", true,QTABLE_INT_TYPE,0)
		AddColumn(tt, 102, " �������", true,QTABLE_INT_TYPE,0)
		
		cols_in_main_window = 102

    CreateWindow(tt)
    -- ����������� ���� ���������
    SetWindowCaption(tt, script_name)
    -- ������ ������� ����
	main_window_x_coord=66
	main_window_y_coord=111
	main_window_height=50+16+16+16
	main_window_width=1100
    SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	--������
	row = InsertRow(tt, -1)
	SetCell(tt, 1, 1, "�������� ����������")
	rows_in_main_window = rows_in_main_window + 1
	
	-- ��������� ��������� ������� ������
	local color_back = RGB(213,234,222)
	for i=2,99,2 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	-- ���� ������������� ����������
	local color_back = RGB(88,222,88)
		for i=7, 13 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	SetColor(tt, QTABLE_NO_INDEX, 6, RGB(230,230,255), RGB(0,0,0), RGB(230,230,255), RGB(0,0,0))
	SetColor(tt, QTABLE_NO_INDEX, 10, RGB(230,230,255), RGB(0,0,0), RGB(230,230,255), RGB(0,0,0))
	
    -- ������������� �� �������
    SetTableNotificationCallback(tt, OnTableEvent)
	
	-- ��������������� ������� ����
	if fileExists(csv_file_name) then
		restoreWindow()
	end
end

-- ������� ������������ ������� � �������
function OnTableEvent(t_id, msg, par1, par2)
--message("msg = "..msg.."   par1 = "..par1.."   par2 = "..par2)
	clicked_row = tonumber(par1)
--   ��� �������� ����
	if msg==24 then
		OnStop()
		is_stopped = true
		is_running=false
	end
	if is_running and msg==11 then
		--��������� ������
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and (msg==11 or msg==4) then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end

	if is_running and msg==11 then --������� ����� ������ ����
		--��������� ������
		Highlight(t_id,par1,par2,000255000,2,500)	
	end
	if is_running and msg==4 then -- ������� ������� ������ ������ ����
		clicked_row = tonumber(par1)
		if tostring(GetCell(tt,current_row_number,3)["image"])~="" then
			InitTable_conf() --  ��������� ���� ������������� �������� �����������
		end
	end
	
		--��� ����� �� "�������� ���������� "
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tt,par1,1)["image"])=="�������� ����������" then
			row_new_instrument = tonumber(par1)
			InitTable_C() --  ��������� ���� � �������� �������
			
			-- ���������� ������� �������� ����
			saveMainWindowTableToCSV()
			
		end
		-- ���������
		if tostring(GetCell(tt,par1,1)["image"])=="��������" and
		CheckAllCellsFilled(par1) then
		
			clicked_row = tonumber(par1)
			InitTable_task() --  ��������� ���� � �������� ��������
		else
			if tostring(GetCell(tt,par1,1)["image"])=="��������" then
				message("�� ���������� ������")
			end
		end
		-- ����������
		if tostring(GetCell(tt,par1,1)["image"])=="���������" then 
			clicked_row = tonumber(par1)
			Class_Code = GetCell(tt,par1,2)["image"]
			Sec_Code = GetCell(tt,par1,3)["image"]
			SetCell(tt, clicked_row, 1, "��������")
		end
	end
	-- ���� �� �������� �����������
	if is_running and (par2==3 or par2==4) and msg==11 and tostring(GetCell(tt,par1,par2)["image"])~="" then
			clicked_row = tonumber(par1)
			InitTable_inf() --  ��������� ���� � �������������� ��������
	end
	-- ������� ������ ����������
	if is_running and msg==6 then
		if (current_column_number == 5    -- ����
		or current_column_number == 7     -- ����
		or current_column_number == 8     -- ������
		or current_column_number == 9     -- �������
		or current_column_number == 11    -- ��������
		)
		and (current_row_number < rows_in_main_window) then
			
			SetCell(tt, current_row_number, 1, "��������")         -- ���������� ������ � ���� ������
			Highlight(tt,current_row_number, 1, 000255000, 2, 100) -- ��������� ����������� ������
			SetPurchased(current_row_number, 0)
			SetSold(current_row_number, 0)
			-- �����
			if par2 >=48 
			and par2 <=57 
			then
				user_input = user_input..tostring(par2-48)
			end
			if current_column_number == 11 then
				-- �����
				if par2 ==46 or par2 ==44 then
					user_input = user_input.."."
				end
				
			end
			
			
			-- ��� �����
			if par2 == 8 then
				user_input = ""
			end
			-- ��������
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
			
			-- ���������� ������
			SetCell(tt, current_row_number, current_column_number, user_input)
			
			-- ����
			if par2 == 13 then
				user_input = ""
				current_column_number = current_column_number + 1
				Highlight(t_id,current_row_number,current_column_number,000255000,2,100)
			end
		end
	end

end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Account_Table=====================================================================================
-- ������� ������������� �������
function Account_Table.new()
    a_id = AllocTable()
    if a_id ~= nil then
        a_table = {}
		setmetatable(a_table, Account_Table)
		a_table.a_id=a_id
		a_table.caption = ""
		a_table.created = false
		a_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		a_table.columns={}
		return a_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Account_Table
test_a_table = Account_Table:new()
-- ������� ������������� �������
function InitTable_A()
    att = test_a_table.a_id
	sleep(10)
	AddColumn(att, 1, "�����", true,QTABLE_STRING_TYPE,25)
	AddColumn(att, 2, "��������", true,QTABLE_STRING_TYPE,44)
    CreateWindow(att)
    -- ����������� ���� ���������
    SetWindowCaption(att, "�����")
    -- ������ ������� ����
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
    -- ������������� �� �������
    SetTableNotificationCallback(att, OnTable_Event_a)
end
-- ������� ������������ ������� � �������
function OnTable_Event_a(a_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(a_id,par1,par2,000255000,2,500)
		-- ��� ������?
		account = tostring(GetCell(a_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 7, account)
		DestroyTable(a_id)
		test_a_table = Account_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� CLIENT_CODE_Table=====================================================================================
-- ������� ������������� �������
function CLIENT_CODE_Table.new()
    cc_id = AllocTable()
    if cc_id ~= nil then
       cc_table = {}
		setmetatable(cc_table, CLIENT_CODE_Table)
		cc_table.cc_id=cc_id
		cc_table.caption = ""
		cc_table.created = false
		cc_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		cc_table.columns={}
		return cc_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� CLIENT_CODE_Table
test_cc_table = CLIENT_CODE_Table:new()
-- ������� ������������� �������
function InitTable_CC()
    cctt = test_cc_table.cc_id
	sleep(1)
	AddColumn(cctt, 1, "���� �������", true,QTABLE_STRING_TYPE,25)
    CreateWindow(cctt)
    -- ����������� ���� ���������
    SetWindowCaption(cctt, "���� �������")
    -- ������ ������� ����
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
    -- ������������� �� �������
    SetTableNotificationCallback(cctt, OnTable_Event_cc)
end
-- ������� ������������ ������� � �������
function OnTable_Event_cc(cc_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(cc_id,par1,par2,000255000,2,500)
		-- ��� ������?
		client_code = tostring(GetCell(cc_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 8, client_code)
		DestroyTable(cc_id)
		test_cc_table = CLIENT_CODE_Table:new()
	end
end

--============================================================����� ���� �������======================================================================================

--==========================================================���� ������� Task_Table=====================================================================================
-- ������� ������������� �������
function Task_Table.new()
    task_id = AllocTable()
    if task_id ~= nil then
        task_table = {}
		setmetatable(task_table, Task_Table)
		task_table.task_id=task_id
		task_table.caption = ""
		task_table.created = false
		task_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		task_table.columns={}
		return task_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Task_Table
test_task_table = Task_Table:new()
-- ������� ������������� �������
function InitTable_task()
    tasktt = test_task_table.task_id
		sleep(1)
		AddColumn(tasktt, 1, "��������", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 7, "�������� ����", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 8, "��� �������", true,QTABLE_STRING_TYPE,16)
    CreateWindow(tasktt)
    -- ����������� ���� ���������
    SetWindowCaption(tasktt, "�������� ��� "..GetCell(tt,clicked_row,4)["image"])
    -- ������ ������� ����
	ox=0
	oy=0
	additional_window_height=40+16+16
	window_width=400
	class_list = getClassesList() -- ������ �������
	class_list=string.sub(class_list, 1, -2)
	vo=0
	row = InsertRow(tasktt, -1)
	SetColor(tasktt, 1, 1, RGB(0, 255, 0), RGB(0, 0, 0), RGB(0, 255, 0), RGB(0, 0, 0))
	SetCell(tasktt, 1, 1, "��������")
	SetCell(tasktt, 1, 7, account)
	SetCell(tasktt, 1, 8, client_code)

	SetWindowPos(tasktt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- ������������� �� �������
    SetTableNotificationCallback(tasktt, OnTable_Event_task)
end

-- ������� ������������ ������� � �������
function OnTable_Event_task(task_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--is_stopped = true
		--is_running=false
	end
	if is_running and msg==11 then
		--��������� ������
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
		InitTable_A() --  ��������� ���� � �������� ��������
	end
	if is_running and par2==8 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_CC() --  ��������� ���� � �������� ��������
	end
	--���� �� "��������"
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tasktt,par1,1)["image"])=="��������" then
			row_on = tonumber(par1)
			if  GetCell(tasktt,row_on,7)["image"]=="" 
			or GetCell(tasktt,row_on,8)["image"]=="" then
				message("�� ��� ���� ���������")
			else
					SetCell(tt, clicked_row, 1, "���������")
					SetCell(tt, clicked_row, 101, "0")
					SetCell(tt, clicked_row, 102, "0")
					DestroyTable(task_id)
					test_task_table = Task_Table:new()
					return
				
			end
		end
	end
	-- ������� ������ ����������
	if is_running and msg==6 then
		-- �����
		if par2 >=48 and par2 <=57 then
			user_input = user_input..tostring(par2-48)
		end
		-- �����
		if par2 == 46 then
			user_input = user_input.."."
		end
		if par2 == 45 then
			user_input = user_input.."-"
		end
		-- ��� �����
		if par2 == 8 then
			user_input = ""
		end
		SetCell(tasktt, current_row_number, current_column_number, user_input)
		-- ����
		if par2 == 13 then
			user_input = ""
			current_column_number = current_column_number + 1
			Highlight(task_id,current_row_number,current_column_number,000255000,2,100)
		end
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� inf_Table=====================================================================================
-- ������� ������������� �������
function Inf_Table.new()
    inf_id = AllocTable()
    if inf_id ~= nil then
        inf_table = {}
		setmetatable(inf_table, Inf_Table)
		inf_table.inf_id=inf_id
		inf_table.caption = ""
		inf_table.created = false
		inf_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		inf_table.columns={}
		return inf_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Inf_Table
test_inf_table = Inf_Table:new()
-- ������� ������������� �������
function InitTable_inf()
    inftt = test_inf_table.inf_id
		sleep(1)
		AddColumn(inftt, 1, "��������", true,QTABLE_STRING_TYPE,25)
		AddColumn(inftt, 2, "��������", true,QTABLE_STRING_TYPE,77)
    CreateWindow(inftt)
    -- ����������� ���� ���������
    SetWindowCaption(inftt, "���������� � �����������")
    -- ������ ������� ����
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- ������ �������
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
    -- ������������� �� �������
    SetTableNotificationCallback(inftt, OnTable_Event_inf)
end
-- ������� ������������ ������� � �������
function OnTable_Event_inf(inf_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		
	end
	if msg==11 then
		--��������� ������
		Highlight(inf_id,par1,par2,000255000,2,500)
		-- ��� ������?
		DestroyTable(inf_id)
		test_inf_table = Inf_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Class_Table=====================================================================================
-- ������� ������������� �������
function Class_Table.new()
    c_id = AllocTable()
    if c_id ~= nil then
        c_table = {}
		setmetatable(c_table, Class_Table)
		c_table.c_id=c_id
		c_table.caption = ""
		c_table.created = false
		c_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		c_table.columns={}
		return c_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Class_Table
test_c_table = Class_Table:new()

-- ������� ������������� �������
function InitTable_C()
    ctt = test_c_table.c_id
	sleep(1)
	AddColumn(ctt, 1, "��� ������", true,QTABLE_STRING_TYPE,25)
	AddColumn(ctt, 2, "�������� ������", true,QTABLE_STRING_TYPE,77)
    CreateWindow(ctt)
    -- ����������� ���� ���������
    SetWindowCaption(ctt, "������� �����")
    -- ������ ������� ����
	ox=222
	oy=222
	additional_window_height=40+17
	window_width=600
	class_list = getClassesList() -- ������ �������
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
    -- ������������� �� �������
    SetTableNotificationCallback(ctt, OnTable_Event_c)
end

-- ������� ������������ ������� � �������
function OnTable_Event_c(c_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(c_id,par1,par2,000255000,2,500)
		-- ��� ������?
		Class_Code = tostring(GetCell(c_id,par1,1)["image"])
		SetCell(tt, row_new_instrument, 2, Class_Code)
		DestroyTable(c_id)
		test_c_table = Class_Table:new()
		InitTable_S()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Sec_Table=====================================================================================
-- ������� ������������� �������
function Sec_Table.new()
    s_id = AllocTable()
    if s_id ~= nil then
        s_table = {}
		setmetatable(s_table, Sec_Table)
		s_table.s_id=s_id
		s_table.caption = ""
		s_table.created = false
		s_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		s_table.columns={}
		return s_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Sec_Table
test_s_table = Sec_Table:new()
-- ������� ������������� �������
function InitTable_S()
    stt = test_s_table.s_id
	sleep(1)
	AddColumn(stt, 1, "��� �����������", true,QTABLE_STRING_TYPE,25)
	AddColumn(stt, 2, "����������", true,QTABLE_STRING_TYPE,55)
    CreateWindow(stt)
    -- ����������� ���� ���������
    SetWindowCaption(stt, "������� ����������")
    -- ������ ������� ����
	ox=55
	oy=55
	additional_window_height=40+15
	window_width=500
    SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height)
	--������
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
    -- ������������� �� �������
    SetTableNotificationCallback(stt, OnTable_Event)
end
-- ������� ������������ ������� � �������
function OnTable_Event(s_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(s_id,par1,par2,000255000,2,500)
		-- ��� ������?
		Sec_Code = tostring(GetCell(s_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tt, row_new_instrument, 3, Sec_Code)
		s_name= getSecurityInfo(Class_Code, Sec_Code).short_name
		SetCell(tt, row_new_instrument, 4, s_name)
		row = InsertRow(tt, -1)
		rows_in_main_window = rows_in_main_window + 1
		SetCell(tt, row, 1, "�������� ����������")
		SetCell(tt, row-1, 1, "��������")
		main_window_height=main_window_height+15
		SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
		DestroyTable(s_id)
		test_s_table = Sec_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Confirmation_Table=====================================================================================
-- ������� ������������� �������
function Confirmation_Table.new()
    conf_id = AllocTable()
    if conf_id ~= nil then
        conf_table = {}
		setmetatable(conf_table, Confirmation_Table)
		conf_table.conf_id=conf_id
		conf_table.caption = ""
		conf_table.created = false
		conf_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		conf_table.columns={}
		return conf_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Confirmation_Table
test_Confirmation_Table = Confirmation_Table:new()

-- ������� ������������� �������
function InitTable_conf()
    conftt = test_Confirmation_Table.conf_id
	sleep(1)
	AddColumn(conftt, 1, " ", true,QTABLE_STRING_TYPE,11)
	AddColumn(conftt, 2, " ", true,QTABLE_STRING_TYPE,11)
    CreateWindow(conftt)
    -- ����������� ���� ���������
	_ = tostring(GetCell(tt,current_row_number,4)["image"])
    SetWindowCaption(conftt, "�� ������ ������� ���������� ".._.." ?")
	_=nil
    -- ������ ������� ����
	ox=55
	oy=55
	additional_window_height=40+15+33
	window_width=444
	row = InsertRow(conftt, -1)
	SetCell(conftt, row, 1, "��")
	SetCell(conftt, row, 2, "���")
    SetWindowPos(conftt, ox, additional_window_height+15, window_width, additional_window_height)
    -- ������������� �� �������
    SetTableNotificationCallback(conftt, OnTable_conf_Event)
end

-- ������� ������������ ������� � �������
function OnTable_conf_Event(conf_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(conf_id,par1,par2,000255000,2,500)
		-- ��� ������?
		local _ = tostring(GetCell(conftt,par1,par2)["image"])
		if _ == "��" then
			-- ������� �������� ������
			deleteRowInMainWindow()
		end
		--message(_)
		DestroyTable(conf_id)
		test_Confirmation_Table = Confirmation_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================

function restoreWindow()
--[[
��������
    restoreWindow - ������� ��� �������������� �������� ����.

��������
    ������ ������� ��������� ������ �� ����� CSV � ������� ������� readCSV() � 
	��������������� ������� � ������� ���� ���������. 
    ����� ��� ������������� ����� ������� � ������� �������� ���� � 
	������������ � ����������� ����� � �������.

���������
    ���
    
������������ ��������
    ���
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
��������
    deleteRowInMainWindow - ������� ��� �������� ������ � ������� ����.

��������
    ������ ������� ������� ��������� ������ �� ������� �������� ����. 
	������� ��� ��������� ������ �� ����� CSV � ������� ������� readCSV(),
    ����� ������� ������ �� ������� ������, 
	����� ������� ������ �� ������� �������� ���� � ������� ������� DeleteRow() 
	� ����� �������������� ������ � ���� CSV � ������� ������� createCSV().

���������
    ���
    
������������ ��������
    ���
]]
	local filepath = csv_file_name
	local data = prepareData()
	table.remove(data, clicked_row) -- ������� ������
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
��������
    createCSV - ������� ��� �������� ����� CSV � ������ � ���� ������.

��������
    ������ ������� ������� ���� CSV � ��������� ����� � ���������� � ���� ������ ��
    ��������� �������. ����������� ����� ���������� �������� ����������� �����.

���������
    filepath (string) - ���� � ������������ ����� CSV.
    data (table) - ������� � �������, ������� ����� �������� � ����. ������ ������ �������
                   ����� ������������ ��� ��������� �����.
    separator (string) - ����������� ����� ���������� �������� � �����.

������������ ��������
    ���
]]
    local file = io.open(filepath, "w") -- ��������� ���� ��� ������
    if file then
        -- ���������� ������ � ����
        for _, row in ipairs(data) do
            file:write(table.concat(row, separator) .. ",\n")
        end
        file:close() -- ��������� ����
        --message("���� CSV ������ �������!")
    else
        message("������ ��� �������� ����� CSV!")
    end
end

function readCSV(filepath, separator) -- tab
--[[
��������
    readCSV - ������� ��� ������ ����� CSV � ����������� ������� ������.

��������
    ������ ������� ��������� ���� CSV � ��������� �����, ������ ��� ���������� � ����������
    ������� ������. ������ ������ ����� ���������� ��������� ������� �������, � ��������
    �������� ��������� ��������� ������������.

���������
    filepath (string) - ���� � ����� CSV, ������� ����� ���������.
    separator (string) - �����������, ������������ ��� ���������� �������� ��������.

������������ ��������
    table - ������� � ������� �� ����� CSV. ���� ���� �� ������ ��� �������� ������ ��
            ����� ������ �����, ������������ nil.
]]
    local file = io.open(filepath, "r") -- ��������� ���� ��� ������
    if file then
        local data = {} -- ������� ������� ��� �������� ������
        for line in file:lines() do
            local row = {}
			for value in string.gmatch(line, "([^" .. separator .. "]*)" .. separator) do
				table.insert(row, value)
			end			
            table.insert(data, row)
        end
        file:close() -- ��������� ����
        return data
    else
        message("������ ��� ������ ����� CSV!")
        return nil
    end
end


function prepareData() -- tab
--[[
��������
    prepareData - ������� ��� ���������� ������� data.

��������
    ������ ������� ������� ������� � ������� �� �������� ����, ���������� � ������� ������� GetCell ��������.

���������

������������ ��������
    table - ������� data � ������� �� GetCell.
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
��������
    restoreTable - ������� ��� �������������� ������� �������� ���� �� ������.

��������
    ������ ������� ��������������� ������� �������� ���� �� ������, ������������ � ������� data.
    ������ �������� �� ������� data ����� �������� � ������ ������� �������� ���� � ������� ������� SetCell.

���������
    data (table) - ������� � ������� ��� �������������� ������� �������� ����.

������������ ��������
    ���
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
��������
    saveMainWindowTableToCSV - ������� ��� ���������� ������� �������� ���� � CSV-����.

��������
    ������ ������� ��������� ������� �������� ���� � ������� CSV. ��� ����� ��� ������� �������������� ������� data � ������� ������� prepareData(), 
    � ����� ������� CSV-���� � ������� ������� createCSV(). 
    
���������
    ���
    
������������ ��������
    ���
]]
	-- ���������� ������� �������� ����
	local filepath = csv_file_name
	local data = prepareData()
	createCSV(filepath, data, separator)
end

function tableEqual(table1, table2) -- bool
--[[
��������
    tableEqual - ������� ��� ��������� ���� ������.

��������
    ������ ������� ���������� ��� ������� table1 � table2 �� ���������. ��� ���������� ��������� ������ ���� ����-�������� � �������� � ����������
    true, ���� ��� �������� � �������� ���������, � false � ��������� ������.

���������
    table1 (table) - ������ ������� ��� ���������.
    table2 (table) - ������ ������� ��� ���������.

������������ ��������
    (boolean) - ��������� ��������� ������: true, ���� ������� �����, � false � ��������� ������.
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
��������
  position - ����������� ����� ����� � �������

��������
  ������� ���������� ���������� ����� � �������� ������� �� �����������.

���������
  �����������.

������������ ��������
  ���������� ����� � �������� ������� (����� �����).
]]--
	local open_lots = 0
	for i = 0,getNumberOf("depo_limits") - 1 do
		-- ���� ������ �� ������� ����������� �� ����� ���� ��
		if getItem("depo_limits",i).sec_code == sec and getItem("depo_limits",i).limit_kind == 2 then
			-- ���� ������ ������� > 0, �� ������� ������� ������� (BUY)
			if getItem("depo_limits",i).currentbal > 0 then 
				BuyVol = getItem("depo_limits",i).currentbal	-- ���������� ����� � ������� BUY
				open_lots = BuyVol
			else   -- ����� ������� ������� ������ (SELL)
				SellVol = math.modf(getItem("depo_limits",i).currentbal) -- ���������� ����� � ������� SELL
				open_lots = SellVol
			end;
		end;
	end;	
	local n,m = math.modf(tonumber(open_lots))
	return tonumber(n)
end

function OpenPrice(class, sec)
--[[
��������
    OpenPrice - ��������� ���� �������� ��� �����������
��������
    ������ ������� ���������� ������ ��� ���������� �����������, 
	�������� ������ � ������� � ���������� ���� ��������. 
	���� ������ �� ������ ��� �������� ������ �����������, ������� ������� ��������� �� ������.
���������
    class (string) - ����� �����������
	sec (string) - ��� �����������
������������ ��������
    (number) - ���� ��������
]]
	local hour = getLocalHourAsNumber()
	-- ���������� ������
	ds, Error = CreateDataSource(class, sec, 60)
	-- ����, ���� ������ ����� �������� � ������� (�� ������, ���� ����� ������ �� ������)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("������ ����������� � �������: "..Error) end
	local Size = ds:Size() -- ���������� ������� ������ (���������� ������ � ��������� ������)
	
	local bar_time = {}
	local bar_hour = 0
	for i = 0, (hour + 2) do
		bar_time = ds:T(Size-i)
		bar_hour = tonumber(bar_time.hour)
		O = ds:O(Size-i)
		
		if bar_hour == 10 then
			ds:Close() -- ������� �������� ������, ������������ �� ��������� ������
			-- message(tostring(O))
			return tonumber(tostring(O))
		end
	end
	ds:Close() -- ������� �������� ������, ������������ �� ��������� ������
end