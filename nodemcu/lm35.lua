--- Configuracion
SSID       = "ssid"
PASSWORD   = "password"
HOST       = "api.thingspeak.com"

 -- Funciones
function Temperatura()
    local r = adc.read(0)
      local c = r * 285 / 1024
    return c
end

function conectar(SSID, PASSWORD, HOST)
        if wifi.sta.status() ~= 5 then
            wifi.setmode(wifi.STATION)
            wifi.sta.config(SSID, PASSWORD)
        end

        if wifi.sta.status() == 5 then
            print("Conectado IP: " .. wifi.sta.getip())           
                        
            tmr.alarm(0, 60000, 1, function()
             socket = net.createConnection(net.TCP,0)
                socket:connect(80,HOST)
                socket:on("connection",function(sck)
                local post_request = generar_datos(HOST)
                sck:send(post_request)
                 print("POST OK") 
                end)
                print("RESET")
            end)
        else
            print("Error de Conexion")
            tmr.alarm(0, 6000, 1, function() conectar(SSID, PASSWORD, HOST) end)
        end
end

function generar_datos(HOST)
    API_KEY = 'api_key'

    int_temperatura = Temperatura()
    YO = wifi.sta.getip()
    print("Temperatura"..int_temperatura.." C\n")

-- Preparamos el POST
    data_post = "api_key="..API_KEY.."&field1="..int_temperatura..""
-- Lanzamos el POST
    cabecera_post = "POST https://"..HOST.."/update HTTP/1.1\r\n"..
     "Host: "..YO.."\r\n"..
     "Connection: close\r\n"..
     "Content-Type: application/x-www-form-urlencoded\r\n"..
     "Content-Length: "..string.len(data_post).."\r\n"..
     "\r\n"..data_post

     return cabecera_post
end

-- Cuerpo
conectar(SSID, PASSWORD, HOST)
