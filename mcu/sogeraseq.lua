local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

local tempoaceso = 200000
local seqrodada = {}
local tamseq = 5
local passo = 1
local ultimavez = 0
local tolerancia = 300000 -- microsegundos
local isGenerating = false

local function geraseq (semente)
    isGenerating = true
  print ("veja a sequencia:")
  tmr.delay(2*tempoaceso)
  print ("(" .. tamseq .. " itens)")
  math.randomseed(semente)
  for i = 1,tamseq do
    seqrodada[i] = math.floor(math.random(1.5,2.5))
    print(seqrodada[i])
    gpio.write(3*seqrodada[i], gpio.HIGH)
    tmr.delay(3*tempoaceso)
    gpio.write(3*seqrodada[i], gpio.LOW)
    tmr.delay(2*tempoaceso)
  end
  print ("agora (seria) sua vez:")
  
  isGenerating = false
end

local function restart(contador)
    geraseq(contador)
    passo = 1
end

local function piscaLed() 
    gpio.write(3*seqrodada[passo], gpio.HIGH)
    tmr.delay(3*tempoaceso)
    gpio.write(3*seqrodada[passo], gpio.LOW)
end

local function checaPasso(contador) 
    if passo == tamseq then
        restart(contador)  
        return
    else
        passo = passo + 1 
    end
end

local function verifica(chave, contador)
if isGenerating == false then
    if contador - ultimavez > tolerancia then
        ultimavez = contador
        if seqrodada[passo] ~= chave then
            print ("Errou a sequencia")
            restart(contador)
            return
        else
            piscaLed()
        end
        checaPasso(contador)
    end
end
end

local function cbchave1 (_,contador)
    return verifica(1, contador)
end


local function cbchave2 (_,contador)
    return verifica(2, contador)
end

local function start (_,contador)
  -- corta tratamento de interrupções
  -- (passa a ignorar chave)
 
  gpio.trig(sw1)
  -- chama função que trata chave
  geraseq (contador)
  gpio.trig(sw1, "down", cbchave1)
  gpio.trig(sw2, "down", cbchave2)
end

gpio.trig(sw1, "down", start)

