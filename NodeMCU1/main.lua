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

local estados = { gerando = 1, conferindo = 2 }

local tempoaceso = 200000
local seqrodada = {}
local tamseq = 5
local atual = 0
local estado = estados.gerando

local function geraseq (semente)
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
  atual = 1
  estado = estados.conferindo
  gpio.trig(sw1, "down", cbchave1)
end

local function confere(chave)
  if chave == seqrodada[atual] then
	atual = atual + 1
	gpio.write(3*chave, gpio.HIGH)
    tmr.delay(3*tempoaceso)
    gpio.write(3*chave, gpio.LOW)
  else
    print ("Voce errou! :(")
    tmr.delay(3*tempoaceso)
	gpio.write(led1, gpio.HIGH)
    tmr.delay(6*tempoaceso)
	gpio.write(led1, gpio.LOW)
	gpio.trig(sw1)
	gpio.trig(sw2)
	return
  end
  if atual > tamseq then
    print("Parabens, voce ganhou! Uhuuul")
    tmr.delay(3*tempoaceso)
	gpio.write(led2, gpio.HIGH)
    tmr.delay(6*tempoaceso)
	gpio.write(led2, gpio.LOW)
	gpio.trig(sw1)
	gpio.trig(sw2)
	return
  end
  if chave == 1 then
    gpio.trig(sw1, "down", cbchave1)
  else
    gpio.trig(sw2, "down", cbchave2)
  end
end

function cbchave1 (_,contador)
  -- corta tratamento de interrupções
  -- (passa a ignorar chave)
  gpio.trig(sw1)
  -- chama função que trata chave
  if estado == estados.gerando then
	geraseq (contador)
  else
    confere(1)
  end
end

function cbchave2 (_,__)
  -- corta tratamento de interrupções
  -- (passa a ignorar chave)
  gpio.trig(sw2)
  
  if estado == estados.conferindo then
    confere(2)
  else
	gpio.trig(sw2, "down", cbchave2)
  end
end

gpio.trig(sw1, "down", cbchave1)
gpio.trig(sw2, "down", cbchave2)