--"Alternator of motor rotation direction using VHDL"
--#########################################################################
-- PROGRAM TO CHANGE THE DIRECTION OF TURN EVERY SECOND (ACCORDING TO THE TIMING USED)

library ieee;
use ieee.std_logic_1164.all;

-- We describe, inputs and outputs of the entity
entity Toggle_Engine_Spin is
port(
------Inputs------
    --Common clock pulse
    clk: in std_logic;
    -- Button to stop or continue cycle
    runstop: in std_logic;
    -- Button to start the sequence 
    BtnIni: in std_logic;
     --Watch out for the end of the timer, 2s
    Time_2s_up: in std_logic;
-------Outputs-------
    --Directions (1) left
    --Directions (0) right
    direction: out std_logic_vector (1 downto 0);
    --Activate start of timer 2s
    iniTime_2s: out std_logic
);
end Toggle_Engine_Spin;

-- We describe the architecture of the entity 
architecture alternator of Toggle_Engine_Spin is
    --values for cycle state state
    type state is(d0,d1,d2);
    --loop state variables
    signal present_estate, future_estate:state; 
    begin
    proceso1: process(present_estate,runstop,BtnIni,Time_2s_up)--Input variables to be treated
        begin
        case present_estate is
            --Attention to start button, nothing happens
            when d0 => 
                if(runstop='1') then
                    iniTime_2s<='0';-- We activate the 2 second timer 
                    if(BtnIni='1') then --Condition to start
                        future_estate<=d1; --tasks finished from this state, we go to the next
                    else direction<="00";--all off
                    end if;
                else future_estate<= d0; -- estado futuro sigue siendo el estado actual
                direction<="00";--all off
                end if; -- Fin de primera condicion
        
            -- Se enciende la vaalvula de agua fria.
            when d1 => 
                if(runstop='1') then
                    iniTime_2s<='1';-- Activamos el timer de 2 segundos
                    if(BtnIni='1') then --Condicion para iniciar
                        if(Time_2s_up='0') -- Si es activado el sensor de nivel
                            future_estate<= d2; --Pasamos al siguiente estado
                        else direction<="01"; ---- Se activa motor con giro a izquierda 
                        end if;
                    else future_estate<=d0; -- Desactivamos giro arternado de motor
                    end if;
                else future_estate <= d1; -- estado futuro sigue siendo el estado actual
                direction<="00";--all off
                end if; -- Fin de primera condicion
    
            -- Se apaga la valvula de agua fria y enciende la de agua caliente durante diez segundos.
            when d2 => 
                if(runstop='1') then
                    iniTime_2s<='1';-- Activamos el timer de 2 segundos
                    if(BtnIni='1') then --Condicion para iniciar
                        if(Time_2s_up='1')then
                            future_estate<=d1; -- Pasamos al siguiente estado
                        else direction<="10"; -- Se activa motor con giro a derecha 
                        end if;
                    else future_estate<=d0; -- Desactivamos giro arternado de motor
                    end if;
                else future_estate <= d2; -- estado futuro sigue siendo el estado actual
                direction<="00";--all off
                end if;
        end case;
    end process proceso1; -- Fin de la descripcion del proceso1
        
    proceso2: process (clk)--Clock pulse detection
        begin
        if(clk'event and clk='1') then -- If clock pulse, future state becomes present
            present_estate <= future_estate;
        end if;
    end process proceso2;-- Fin de la descripcion del proceso2
end alternator; --End of architecture description
