--- Configuracion
SSID       = "SSID"
PASSWORD   = "PASSWORD"
HOST       = "api.thingspeak.com"

-- Cuerpo
conectar(SSID, PASSWORD, HOST)

 -- Funciones
function Temperatura()
    local r = adc.read(0)
      local c = r * 285 / 1024
    return c
end

function conectar(SSID, PASSWORD, HOST)
        wifi.setmode(wifi.STATION)
        wifi.sta.config(SSID, PASSWORD)
        
        if wifi.sta.status() == 5 then
            print("Conectado IP: " .. wifi.sta.getip())
            tmr.alarm(0, 600000, 1, function()
                socket = net.createConnection(net.TCP,0)
                socket:connect(80,HOST)
                socket:on("connection",function(sck)
                local post_request = generar_datos(HOST)
                sck:send(post_request)
                end)
            end)
        else
            print("Error de Conexion")
            tmr.alarm(0, 60000, 1, function() conectar(SSID, PASSWORD, HOST) end)
        end

end

function generar_datos(HOST)
    API_KEY = "API_KEY"

    temperatura = Temperatura()
    host = wifi.sta.getip()
    print("Temperatura"..temperatura.."C\n")

-- Preparamos el POST
    data_post = "api_key="..API_KEY.."&field1="..temperatura

    print(data_post)

    cabecera_post = "POST https://"..HOST.."/update HTTP/1.1\r\n"..
     "Host: "..HOST.."\r\n"..
     "Connection: close\r\n"..
     "Content-Type: application/x-www-form-urlencoded\r\n"..
     "Content-Length: "..string.len(data_post).."\r\n"..
     "\r\n"..data_post

     print(cabecera_post)

     return cabecera_post
end
