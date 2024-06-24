# bash_profile

Este projeto foi criado para exemplificar como pode-se criar operações avançadas no bash e integrá-las como uma extensão de operações do git, permitindo seu uso inclusive por outros terminais que consigam reconhecer operações do git.

## Operações disponíveis

Esse projeto implementa extensões para a criação de branchs, operação de push origin para a branch atual, exclusão de todas as branchs locais sem merge pendente e realização de commits com formatações especificas, sendo essas:

- Branchs são criadas com um termo representativo e o número de uma issue, Ex: `FIX/1234`
- Commits são criados com a definição de um tipo, escopo, descrição e uma lista de issues, Ex:

```md
WIP(Scope): Descrição do commit

- #1234
```

O padrão apresentado está em acordo com o conventional commits: [https://www.conventionalcommits.org/pt-br/v1.0.0/](https://www.conventionalcommits.org/pt-br/v1.0.0/)

Esse pacote implementa uma função de ajuda que lista as operações disponíveis e pode ser acionada com a chamada da função `mygit_helper` ou chamando a função principal com o operador ? `mygit -?`

## Configuração

Para configurar este projeto em seu ambiente basta seguir os passos listados abaixo

- Abra o terminal e execute o seguinte comando `cd ~` ou `cd $HOME`, isso acessará a pasta raiz do seu usuário
- Execute o comando `touch .bashrc` para criar um arquivo chamado .bashrc, se você estiver no windows pode usar o comando `cd > .bashrc`
  - Caso o arquivo já exista é possível ignorar essa etapa
  - É possível criar este arquivo com um nome qualquer, como `.my-bashrc`
- Tendo o arquivo disponível, é necessário abrir o mesmo para edita-lo
  - Se você possuir o VS code instalado, pode usar o comando `code .bashrc`
  - Se estiver no windows pode usar o comando `notepad .bashrc`
  - Se estiver no linux pode usar o comando `vim .bashrc`
- Com o editor de sua preferência aberto, copie o conteúdo do arquivo .bashrc deste repositório e cole no arquivo criado
  - Caso prefira, você pode baixar o arquivo .bashrc deste repositório, e copia-lo para a pasta raiz do seu usuário, pulando todas as etapas anteriores.
- Para que as funções criadas no arquivo fiquem acessíveis, no terminal bash execute o comando `source .bashrc`
  - Esse comando vai habilitar a execução de todas as funções públicas do arquivo, você pode testar a funcionalidade executando o comando `mygit -v`
  - Essas funções ainda não estão disponíveis no terminal do windows, elas só podem ser executadas como o exemplo citado acima por meio do bash. Para que possa ser executado pelo windows, é necessário criar um alias no git
- Para conseguir executar as funções desse arquivo como extensões do git, execute o seguinte comando `git config --global alias.my '!bash -c "source $HOME/.bashrc && mygit \"$1\" \"$2\" \"$3\" ${*:4} "'`
  - Esse comando cria um alias global para o git com o nome `my`, garante a inicialização do arquivo .bashrc, e direciona a função mygit passando todos os parâmetros fornecidos para o alias
- Agora já é possível chamar a função `mygit` com o comando `git my`, e este pode ser chamado inclusive pelo terminal do windows

## Problemas conhecidos

Ao usar terminais personalizados no linux, como o zsh, o acesso direto a funções como `mygit` podem não estar disponíveis, neste caso consulte o manual do terminal utilizado para descobrir como incluir as funções personalizadas ao seu terminal. Em qualquer terminal personalizado onde a função direta não possa ser acessada, o comando via alias do git é disponibilizado corretamente.

Alguns terminais, como o zsh podem apresentar erro ao realizar operações com o comando `-?`, isso ocorre pois em alguns desses terminais o caracter `?` é usado para descrever qualquer outro caracter. O problema pode ser resolvido colocando o texto que contem esse caracter entre aspas, ou você pode consultar o manual do seu terminal para verificar se o mesmo oferece um meio de desabilitar esse comportamento.
