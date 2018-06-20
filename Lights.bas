' Outdoor light controller

Symbol LDT = C.0		' Light dependent transistor input	
Symbol MOVE1 = pinC.1	' Movement sensor input 1
Symbol MOVE2 = pinC.2	' Movement sensor input 2
Symbol SENSPWR = B.1	' Movement sensor power
Symbol LIGHT1 = B.2	' Light bank 1
Symbol LIGHT2 = B.3	' Light bank 2
Symbol STATUS = B.4	' Status LED

Symbol LIGHT = W0			' Ambient light reading
Symbol LIGHT_TIMER = W1		' Light1 timer
Symbol LIGHT_TIMEOUT = 115	' 300s / 2.6s = about 5 minutes of light
Symbol LIGHT_THRESH = 100	' Daylight threshold
Symbol SLEEP_TIME = 2		' 4.6 seconds
Symbol STATUS_FLASH = 50	' Status LED flash

StartLoop:

high STATUS
pause STATUS_FLASH
low STATUS

' Read light sensor. If > LIGHT_THRESH, turn off SENSPW, sleep
ReadADC10	LDT, LIGHT

if LIGHT > LIGHT_THRESH then
	' Daylight, sleep
	low	SENSPWR	
	sleep	SLEEP_TIME	
	LIGHT_TIMER = 0 
else
	high	SENSPWR
	' Night, check for movement
	if MOVE1 = 1 or MOVE2 = 1 then
		' Movement, switch ON and set timeout
		high	LIGHT1
		high 	LIGHT2
		LIGHT_TIMER = LIGHT_TIMEOUT
	else
		if LIGHT_TIMER = 0 then
			low	LIGHT1
			low	LIGHT2
		else
			LIGHT_TIMER = LIGHT_TIMER - 1	
		endif		
	endif	
	sleep	SLEEP_TIME	
endif

goto StartLoop
