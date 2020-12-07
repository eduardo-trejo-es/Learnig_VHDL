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
    Inicio: in std_logic;
     --Watch out for the end of the timer, 2s
    Time_2s_up: in std_logic;
-------Outputs-------
    --Direcciones(1) izquierda
    --Direcciones(0) derecha
    Direcciones: out std_logic_vector (1 downto 0);
    --Activar inicio de timer 12s
    iniTime_2s: out std_logic
);
end Toggle_Engine_Spin;

-- Describimos la arquitectura de la entidad 
architecture Completa of Toggle_Engine_Spin is
    --valores para estado de estados de ciclo
    type estados is(d0,d1,d2);
    --variables de estados de ciclo
    signal edo_presente, edo_futuro:estados; 
    begin
    proceso1: process(edo_presente,runstop,Inicio,Time_2s_up)--Variables de entrada a tratar
        begin
        case edo_presente is
            --Atención a boton inicio, no ocurre nada
            when d0 => 
                if(runstop='1') then
                    iniTime_2s<='0';-- Activamos el timer de 2 segundos 
                    if(Inicio='1') then --Condicion para iniciar
                        edo_futuro<=d1; --Termino tareas de este estado, pasamos al siguiente
                    else Direcciones<="00";--Todo desactivado
                    end if;
                else edo_futuro<= d0; -- estado futuro sigue siendo el estado actual
                Direcciones<="00";--Todo desactivado
                end if; -- Fin de primera condicion
        
            -- Se enciende la vaalvula de agua fria.
            when d1 => 
                if(runstop='1') then
                    iniTime_2s<='1';-- Activamos el timer de 2 segundos
                    if(Inicio='1') then --Condicion para iniciar
                        if(Time_2s_up='0') -- Si es activado el sensor de nivel
                            edo_futuro<= d2; --Pasamos al siguiente estado
                        else Direcciones<="01"; ---- Se activa motor con giro a izquierda 
                        end if;
                    else edo_futuro<=d0; -- Desactivamos giro arternado de motor
                    end if;
                else edo_futuro <= d1; -- estado futuro sigue siendo el estado actual
                Direcciones<="00";--Todo desactivado
                end if; -- Fin de primera condicion
    
            -- Se apaga la valvula de agua fria y enciende la de agua caliente durante diez segundos.
            when d2 => 
                if(runstop='1') then
                    iniTime_2s<='1';-- Activamos el timer de 2 segundos
                    if(Inicio='1') then --Condicion para iniciar
                        if(Time_2s_up='1')then
                            edo_futuro<=d1; -- Pasamos al siguiente estado
                        else Direcciones<="10"; -- Se activa motor con giro a derecha 
                        end if;
                    else edo_futuro<=d0; -- Desactivamos giro arternado de motor
                    end if;
                else edo_futuro <= d2; -- estado futuro sigue siendo el estado actual
                Direcciones<="00";--Todo desactivado
                end if;
        end case;
    end process proceso1; -- Fin de la descripcion del proceso1
        
    proceso2: process (clk)--Deteccion de pulsos de reloj
        begin
        if(clk'event and clk='1') then -- Si pulso de reloj, estado fututo pasa a ser presente
            edo_presente <= edo_futuro;
        end if;
    end process proceso2;-- Fin de la descripcion del proceso2
end Completa; --Fin de la descripcion de la arquitectura
