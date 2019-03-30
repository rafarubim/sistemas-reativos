Gabriel Busquim
Rafael Rubim

Funcionamento do MiniProjeto 1:

Programa inicia com display de 7 segmentos mostrando 00:00(Modo 1).
Cada vez que KEY 3 é pressionada, avança para o próximo modo.
Nos casos dos modos 4 e 5, apertar KEY 3 torna possível alterar os minutos ao invés das horas.
Apertá-lo novamente passa para o próximo modo (no caso do modo 5, volta para o modo 1). 

Modo 1 (inicial) -> mostra horas e minutos.Led 1 deve estar acesso . Quando KEY 1 E KEY 3 forem pressionadas simultaneamente, o relógio vai para o Modo 1 descrito acima. Neste modo,alarme está desligado.  

Modo 2 -> mostra horas e minutos, mas com o alarme ligado. Caso alarme ainda não tenha sido setado, ele pode ser setado inicialmente como 00:00. Led 2 deve estar aceso. Quando o alarme estiver tocando, deve-se escolher uma das chaves para fazer a buzina parar de tocar. Somente quando o relógio está neste modo e no modo 3 é que o alarme pode tocar.

MOdo 3 -> mostra horário do alarme.Somente quando o relógio está neste modo e no modo 2 é que o alarme pode tocar.Led 3 deve estar aceso. 

Modo 4 -> Permite alterar o horário. Assim que entra nesse modo, as horas começam a piscar. Apertar KEY 3 possibilita alterar os minutos. Apertar KEY 2 aumenta o tempo em questão (hora ou minuto) em 1. Se 10 segundos se passarem sem nada ser pressionado, relógio volta para o estado 1. Led 4 deve estar aceso.    

Modo 5 -> Permite alterar o horário do alarme. Assim que entra nesse modo, as horas começam a piscar. Apertar KEY 3 possibilita alterar os minutos. Apertar KEY 2 aumenta o tempo em questão (hora ou minuto) em 1. Se 10 segundos se passarem sem nada ser pressionado, relógio volta para o estado 1. Led 5 deve estar aceso(não existe LED 5, logo podemos acender 2 leds ao mesmo tempo). Lembrando que o próximo estado é o 1!

Lembrar que devemos incluir pelo menos uma funcionalidade adicional(função soneca para o alarme ou cronômetro).Também devemos setar uma combinação de LEDs para este novo modo. 


Observação óbvia,porém importante: Quando os minutos passarem de 59, acrescentar 1 na hora!   
  

