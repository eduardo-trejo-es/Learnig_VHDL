--Automation project of a washing machine using VHDL
--#########################################################################
-- PROGRAM FOR WASHING CYCLE IN 4 STAGES

library ieee;
use ieee.std_logic_1164.all;

-- We describe, inputs and outputs of the entity
entity Wash_cycle is
port(
------Inputs------
    --Common clock pulse
    clk: in std_logic;
    -- Button to stop or continue cycle
    runstop: in std_logic;
    -- Button to start the sequence (1)
    -- Level sensor (0)
    DataIn: in std_logic_vector (1 downto 0); 
    -- Watch out for the end of the timer, 10s
    Time_10s_up: in std_logic;
    -- Watch out for the end of the timer, 12s
    Time_12s_up: in std_logic;
     -- Watch out for the end of the timer, 15s
    Time_15s_up: in std_logic;
-------Outputs-------
    -- Hot water valve (3)
    --Cold water valve (2)
    -- Drain valve (1)
    --Washing machine motor (0)
    --start 12 second timer
    --Start 15 second timer
    DataOut: out std_logic_vector (3 downto 0); -- shift register output signals
    --Activate start of timer 10s
    iniTime_10s: out std_logic;
    --Activate start of timer 12s
    iniTime_12s: out std_logic;
    --Activate start of timer 15s
    iniTime_15s: out std_logic
);
end Wash_cycle;

-- we describe the architecture of the entity
architecture Completa of Wash_cycle is
    --values for state of cycle states
    type state is(d0,d1,d2,d3,d4,d5);
    --cycle state variables
    signal present_estate, future_estate:state; 
    begin
    description_1: process(present_estate,runstop,DataIn,Time_10s_up,Time_12s_up,Time_15s_up)--Input variables to be treated
        begin
        case present_estate is
            --Attention to start button, nothing happens
            when d0 => 
                if(runstop='1') then 
                    if(DataIn='10') then --Condition to change state
                        future_estate<=d1; --tasks finished from this state, we go to the next
                    else DataOut<="0000";--All off
                    end if;
                else future_estate<= d0; -- future state remains current state
                end if; -- End of first condition
        
            -- The cold water valve turns on.
            when d1 => 
                if(runstop='1') then
                    if(DataIn='01') -- If the level sensor is activated
                        future_estate<= d2; --We go to the next state
                    else DataOut<="0100"; --Cold water valve is activated
                    end if;
                else future_estate <= d1; -- future state remains current state
                DataOut<="0000";--All off
                end if; -- End of second condition
    
            -- The cold water valve is turned off and the hot water valve on for ten seconds.
            when d2 => 
                if(runstop='1') then
                    iniTime_10s<='1';-- We activate timer 10s
                    if(Time_10s_up='1')then
                        future_estate<=d3; -- We go to the next state
                        iniTime_10s<='0';-- Deactivate the 10 second timer
                    else DataOut<="1000"; -- Hot water valve is activated 
                    end if;
                else future_estate <= d2; -- future state remains current state
                DataOut<="0000";--All off
                end if;--End of third condition
            
            -- Turn off the hot water valve and start the engine.
            when d3 => 
                if(runstop='1') then
                    iniTime_12s<='1'; --We activate timer 12s
                    if(Time_12s_up='1')then
                        future_estate<=d4; -- We go to the next state
                        iniTime_12s<='0';--Disable timer
                    else DataOut<="0001"; -- activate motor and wash
                    end if;
                else future_estate <= d3; -- future state remains current state
                DataOut<="0000";--All off
                end if;
            
            -- Stop the engine and turn on the drain valve  
            when d4 =>
                if(runstop='1') then
                    iniTime_15s<='1';--We activate timer 15s 
                    if(Time_15s_up='1')then
                        future_estate<= d0; -- We go to the next state
                        iniTime_15s<='0';--Disable timer
                    else DataOut<="0010"; -- Drain valve is activated
                    end if;
                else future_estate <= d4; -- future state remains current state
                DataOut<="0000";--All off
                end if;
        end case;
    end process proceso1; -- End of process description_1
        
    process_2: process (clk)--Clock pulse detection
        begin
        if(clk'event and clk='1') then -- If there is a clock pulse, future state becomes present
            present_estate <= future_estate;
        end if;
    end process process_2;-- End of the description of process_2
end Completa; --End of architecture description
