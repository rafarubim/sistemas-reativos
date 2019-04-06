Gabriel Busquim - 1510549
Rafael Rubim - 1511068

MiniProjeto 1: Relógio Despertador com Arduíno e placa multifunção

Funcionamento:

Os Leds indicam em qual modo está o relógio despertador. Foi utilazada a seguinte configuração para cada modo:

Modo 1 -> Led 1 aceso
Modo 2 -> Led 2 aceso
Modo 3 -> Led 3 aceso
Modo 4 -> Led 4 aceso
Modo 5 -> Leds X e Y acesos
Modo 6 -> Leds X e Y acesos

Caso os botões 1 e 3 sejam pressioandos simultaneamente, o relógio vai para o Modo 1.Descrição de cada modo:

Modo 1:
Este modo mostra o horário atual.Quando o programa é carregado, o display de 7 segmentos mostra o horário default (00:00). 
Caso o botão 3 seja pressionado,avança-se para o Modo 2.

Modo 2:
Este modo mostra o horário atual, mas com o alarme ligado. Caso o horário do alarme ainda não tenha sido acertado, ele não
tocará(?). Apertar o botao X faz o alarme parar de tocar.
Caso o botão 3 seja pressionado,avança-se para o Modo 3.

Modo 3:
Este modo mostra o horário programado para o alarme tocar. Caso o horário do alarme ainda não tenha sido acertado, o display de 7 segmentos mostra o horário de alarme default (00:00). O alarme toca neste modo(?).
Caso o botão 3 seja pressionado,avança-se para o Modo 4.

Modo 4:
Este modo permite alterar o horário do relógio. Assim que ele entra neste modo, é possível alterar as horas (que começam a piscar).
Cada vez que o botão 2 é apertado, aumenta-se em 1 seu valor. Caso o botão 3 seja apertado, torna-se possível alterar os minutos.
Assim como antes, cada vez que o botão 2 é apertado seu valor aumenta em 1 unidade. Se 10 segundos se passarem sem que nada tenha sido pressioado, tanto quando se está alterando as horas quanto quando se está alterando os minutos, o relógio volta para o Modo 1.

Modo 5:
Este modo permite alterar o horário do alarme. Assim que o relógio entra neste modo, é possível alterar as horas (que começam a piscar).
Cada vez que o botão 2 é apertado, aumenta-se em 1 seu valor. Caso o botão 3 seja apertado, torna-se possível alterar os minutos.
Assim como antes, cada vez que o botão 2 é apertado seu valor aumenta em 1 unidade. Se 10 segundos se passarem sem que nada tenha sido pressioado, tanto quando se está alterando as horas quanto quando se está alterando os minutos, o relógio volta para o Modo 1.

Modo 6:
Este modo representa um cronômetro, funcionalidade adicional criada por nós. Funcionamento a definir.
