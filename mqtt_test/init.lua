-- Configuration
SSID   = "<ssid>"
KEY    = "<key>"
BROKER = "mqtt.opensensors.io"          -- Ip/hostname of MQTT broker
BRPORT = 1883                           -- MQTT broker port
BRUSER = "<user>"                       -- If MQTT authenitcation is used then define the user
BRPWD  = "<pw>"                     -- The above user password
CLIENTID = "<client>"                       -- The MQTT ID. Change to something you like
TOPIC = "/orgs/exmpale"
PIN_GREEN_LED = 2
PIN_RED_LED = 1

sampletime = 10000

-- DO NOT CHANGE BELOW THIS LINE
-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing whne the previous hasn't ended

tmr.delay(100000)

-- Connect to WIFI
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)
wifi.sta.config(SSID, KEY)

-- Print boot message
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())

-- pub
function publish_mqtt(msg)
    print("Publish to " .. TOPIC .. ":" .. msg)
    print('heap: ',node.heap())

    if pub_sem == 0 then
        pub_sem = 1
        m:publish(TOPIC,msg,0,0,function(conn)
            print("sent")
            pub_sem = 0
        end)
    else
        print("Oh noes! Semaphore was 1, stop nao!")
    end
end

function connect()
    print "Connecting to MQTT broker. Please wait..."
    m:connect( BROKER , BRPORT, 0, function(conn)
        print("Connected to MQTT:" .. BROKER .. ":" .. BRPORT .." as " .. CLIENTID )
        tmr.alarm(0, sampletime, 1, function()
            -- dummy data
            publish_mqtt('{"durP1": "781799","ratioP1":"2.6059966666667","P1":"1349.3993182994","durP2":"587329","ratioP2":"1.9577633333333","P2":"1012.3463188052"}')
        end)
    end)
end

-- main
function main()
    print("Main program")

    m = mqtt.Client( CLIENTID, 60, BRUSER, BRPWD)
    m:on("offline", function(conn)
        print("Disconnected from broker...")
        print(node.heap())
        -- reconnect
        connect()
    end)

    -- Connect to the broker
    connect()
end

-- do main
main()
