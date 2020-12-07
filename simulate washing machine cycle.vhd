--“Proyecto de automatizacion de una lavadora utilizando VHDL 
--#########################################################################
-- PROGRAMA PARA CICLO DE LAVADO EN 4 ETAPAS

library ieee;
use ieee.std_logic_1164.all;

-- Describimos, entradas y salidas de la entidad
entity Ciclo_lavado is
port(
------Entradas------
    --Pulso de reloj comun
    clk: in std_logic;
    -- Boton para detener o continuar con ciclo
    runstop: in std_logic;
    -- Boton para dar incio a la secuencia (1)
    -- Sensor de nivel (0)
    DatoIn: in std_logic_vector (1 downto 0); 
    -- Atento a final de time, 10s
    Time_10s_up: in std_logic;
    -- Atento a final de time, 12s
    Time_12s_up: in std_logic;
     -- Atento a final de time, 15s
    Time_15s_up: in std_logic;
-------Salidas-------
    --Valvula de agua caliente (3)
    --Valvula de agua fria (2)
    --Valvula de desague (1)
    --Motor de lavadora (0)
    --iniciar temporizador de 12 segundos
    --Iniciar temporizador de 15 segundos
    DatoOut: out std_logic_vector (3 downto 0); -- senales de salida del registro de corrimiento
    --Activar inicio de timer 10s
    iniTime_10s: out std_logic;
    --Activar inicio de timer 12s
    iniTime_12s: out std_logic;
    --Activar inicio de timer 15s
    iniTime_15s: out std_logic
);
end Ciclo_lavado;

-- Describimos la arquitectura de la entidad 
architecture Completa of Ciclo_lavado is
    --valores para estado de estados de ciclo
    type estados is(d0,d1,d2,d3,d4,d5);
    --variables de estados de ciclo
    signal edo_presente, edo_futuro:estados; 
    begin
    proceso1: process(edo_presente,runstop,DatoIn,Time_10s_up,Time_12s_up,Time_15s_up)--Variables de entrada a tratar
        begin
        case edo_presente is
            --Atención a boton inicio, no ocurre nada
            when d0 => 
                if(runstop='1') then 
                    if(DatoIn='10') then --Condicion para cambiar de estado 
                        edo_futuro<=d1; --Termino tareas de este estado, pasamos al siguiente
                    else DatoOut<="0000";--Todo desactivado
                    end if;
                else edo_futuro<= d0; -- estado futuro sigue siendo el estado actual
                end if; -- Fin de primera condicion
        
            -- Se enciende la vaalvula de agua fria.
            when d1 => 
                if(runstop='1') then
                    if(DatoIn='01') -- Si es activado el sensor de nivel
                        edo_futuro<= d2; --Pasamos al siguiente estado
                    else DatoOut<="0100"; --Se activa valvula de agua fria 
                    end if;
                else edo_futuro <= d1; -- estado futuro sigue siendo el estado actual
                DatoOut<="0000";--Todo desactivado
                end if; -- Fin de primera condicion
    
            -- Se apaga la valvula de agua fria y enciende la de agua caliente durante diez segundos.
            when d2 => 
                if(runstop='1') then
                    iniTime_10s<='1';-- Activamos el timer de 10 segundos
                    if(Time_10s_up='1')then
                        edo_futuro<=d3; -- Pasamos al siguiente estado
                        iniTime_10s<='0';-- Desactivo el timer de 10 segundos
                    else DatoOut<="1000"; -- Se activa valvula de agua caliente 
                    end if;
                else edo_futuro <= d2; -- estado futuro sigue siendo el estado actual
                DatoOut<="0000";--Todo desactivado
                end if;
            
            -- Apagar la valvula de agua caliente y encender el motor.
            when d3 => 
                if(runstop='1') then
                    iniTime_12s<='1'; --Activamos timer 
                    if(Time_12s_up='1')then
                        edo_futuro<=d4; -- Pasamos al siguiente estado
                        iniTime_12s<='0';--Desactivamos timer 
                    else DatoOut<="0001"; -- Se activa valvula de agua caliente
                    end if;
                else edo_futuro <= d3; -- estado futuro sigue siendo el estado actual
                DatoOut<="0000";--Todo desactivado
                end if;
            
            -- Apagar el motor y encender la valvula de desague   
            when d4 =>
                if(runstop='1') then
                    iniTime_15s<='1';--Activamos timer 
                    if(Time_15s_up='1')then
                        edo_futuro<= d0; -- Pasamos al siguiente estado
                        iniTime_15s<='0';--Desactivamos timer 
                    else DatoOut<="0010"; -- Se activa valvula de agua caliente
                    end if;
                else edo_futuro <= d4; -- estado futuro sigue siendo el estado actual
                DatoOut<="0000";--Todo desactivado
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