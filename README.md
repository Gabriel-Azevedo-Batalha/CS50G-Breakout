# CS50G - Breakout
Repositório com a tarefa do Breakout do Curso CS50's Introduction to Game Development onde o objetivo é:
- Adicionar um powerup que adiciona 2 bolas extras
- Adicionar mecânica de aumentar  a pá dependendo do número de pontos e diminuir caso perca vida (Implementado diferente)
- Adicionar bloco trancado que necessita o powerup chave para ser destrancado

Repositório original do curso: https://github.com/games50/breakout

## Powerups
Além dos poweups requisitados da tarefa outros foram implementados, além disso a mecânica de dimiuir e aumentar a pá foi substituída por powerups. São eles:

- X Vermelho: Jogador perde 1000 pontos
- X Verde: Jogador ganha 1000 pontos
- Coração Roxo: Jogador perde uma vida
- Rosto Roxo: Jogador congela por 3 segundos
- Aumento: aumenta a pá do Jogador
- Diminuição: diminui a pá do Jogador
- Bola Grande: acrescenta um buff de que 5 acertos (Acumulativo) faz a bola causar 2 de dano 
- Bola Pequena: remove 5 acertos do buff de dano. Valores negativos podem ser alcançados, mas vão aumentando até 0 com cada acerto
- Bola com sinal **+**: Acrescenta 2 bolas extras
- Chave: Remove o cadeado do bloco trancado. Só aparece se o bloco existir

## Controles
- Esquerda e Direita: **LEFT** e **RIGHT**
- Sacar: **ENTER**
- Pausar **ESPAÇO**