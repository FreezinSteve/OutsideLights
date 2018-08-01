' Outdoor light controller
' B.0 and C.5 are used for comms
' Use Cx pins for input, Bx for output

Symbol LDT = C.0			' Light dependent transistor input	
Symbol MOVE1 = pinC.1		' Movement sensor input
Symbol SPALIGHT = pinC.2	' Push button switch
Symbol SENSPWR = B.1		' Movement sensor power
Symbol LIGHT1 = B.2		' Light bank 1
Symbol LIGHT2 = B.3		' Light bank 2
Symbol STATUS = B.4		' Status LED

Symbol LIGHT = W0			' Ambient light reading
Symbol LIGHT_TIMER1 = W1	' Light1 timer
Symbol LIGHT_TIMEOUT1 = 115	' 300s / 2.6s = about 5 minutes of light after last movement
Symbol LIGHT_TIMER2 = W2	' Light2 timer
Symbol SPALIGHTSTATE = B6	' State of Spa lights	
Symbol SPALIGHT_FLASH = 500	' 1/2 second delay
Symbol LIGHT_TIMEOUT2 = 23	' About 1 minute after last movement
Symbol LIGHT_THRESH = 200	' Daylight threshold
Symbol SLEEP_DAY_TIME = 4	' 10.4 seconds scan rate 
Symbol SLEEP_NIGHT_TIME = 1	' 2.6 seconds scan rate
Symbol STATUS_FLASH = 50	' Status LED flash time
Symbol SPALIGHT_TIMEOUT = 2700	' Spa lights on for ~2 hours
StartLoop:

high STATUS
pause STATUS_FLASH
low STATUS

' Read light sensor. If > LIGHT_THRESH, turn off SENSPW, sleep
ReadADC10	LDT, LIGHT
' DEBUG
'sertxd("LIGHT=",#LIGHT,13,10)

if LIGHT > LIGHT_THRESH then
	' Daylight, sleep
	low	SENSPWR	
	low	LIGHT1
	low	LIGHT2
	LIGHT_TIMER1 = 0 
	LIGHT_TIMER2 = 0 
	SPALIGHTSTATE = 0
	disablebod
	sleep	SLEEP_DAY_TIME	
else
	high	SENSPWR
	' Night, check for movement on sensor 1
	if MOVE1 = 0 then  ' LO = MOVEMENT
		' Movement, switch ON and set timeout
		high	LIGHT1
		high	LIGHT2
		if LIGHT_TIMER1 < LIGHT_TIMEOUT1 then
			' Don't overwrite timeout from SPALIGHT
			LIGHT_TIMER1 = LIGHT_TIMEOUT1
		endif		
		LIGHT_TIMER2 = LIGHT_TIMEOUT2
	else
		if LIGHT_TIMER1 = 0 then
			low	LIGHT1			
		else
			LIGHT_TIMER1 = LIGHT_TIMER1 - 1	
		endif		
		if LIGHT_TIMER2 = 0 then
			low	LIGHT2
		else
			LIGHT_TIMER2 = LIGHT_TIMER2 - 1	
		endif		
	endif	
	if SPALIGHT = 0 then	' Button DOWN
		' Toggle state
		if SPALIGHTSTATE = 0 then
			SPALIGHTSTATE = 1
			' Flash lights to show we've locked them ON
			high	LIGHT1
			pause SPALIGHT_FLASH
			low	LIGHT1
			pause SPALIGHT_FLASH
			high	LIGHT1
			pause SPALIGHT_FLASH
			low 	LIGHT1
			pause SPALIGHT_FLASH
			high	LIGHT1	
			LIGHT_TIMER1 = SPALIGHT_TIMEOUT
		else
			' Reset STATE and timers
			LIGHT_TIMER1 = 0
			LIGHT_TIMER2 = 0
			SPALIGHTSTATE = 0
		endif
	endif
	disablebod
	sleep	SLEEP_NIGHT_TIME	
endif
enablebod
goto StartLoop