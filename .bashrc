mygit_create_branch() {
  if [[ $1 == '-?' ]] ; then
    echo 'Função para inicializar a operação de criação de branchs'
    echo 'Parâmetros aceitáveis da função -b'
    echo '1º {type} Corresponde aos tipos de branchs aceitáveis'
    # Artefatos da azure
    echo '    FEATURE - Extensa implementação com poucos ciclos de merge para a branch default'
    echo '    US      - User Story, parte de uma feature, com mergers regulares para a branch default ou Feature'
    echo '    TASK    - Parte de uma US'
    echo '    BUG     - Correções de BUGs abertos para USs ou Features'
    echo '    MANUT   - Correções de manutenções abertas por usuários'
    # Tipos aceitos no texto de commit
    echo '    CHORE  - Alterações de tarefas de build, automações e pipelines'
    echo '    DOCS   - Adição ou alterações de documentações'
    echo '    FEAT   - Nova funcionalidade ou rotina'
    echo '    FIX    - Correções de bugs'
    echo '    REFACT - Refatoração de código'
    echo '    TEST   - Novo teste automatizado'
    echo '    TYPO   - Corrige erros de digitação ou palavras escritas errado'
    echo '    WIP    - Alterações que ainda não foram terminadas'
    echo '2º {wi} Corresponde ao número da issue'
    return
  fi

  local type=$1
  local work_item=$2
  local accepted_types=(FEATURE, US, TASK, BUG, MANUT, CHORE, DOCS, FEAT, FIX, REFACT, TEST, TYPO, WIP)

  # Função que lida com a escolha do tipo da branch
  _handle_type_branch() {

    # Converte todos os caracteres para maiúsculo
    type=${type^^}
    local re="^${type}, |, ${type}$|, ${type},"

    # Verifica se possui algum valor preenchido
    if [ ! -z $type ] ; then

      # Verifica se o valor preenchido é valido
      if [[ ${accepted_types[@]} =~ $re ]] ; then
        return

      # Imprime mensagem de erro para valores inválidos
      else
        echo "'$type' não é um tipo valido"
      fi
    fi

    # Solicita que seja informado um valor
    echo "Informe um dos seguintes tipos: ${accepted_types[*]}"
    read read_type
    type=$read_type

    _handle_type_branch
  }

  # Função que lida com o numero da WI
  _handle_work_item_branch() {
    local re='^[0-9]+$'

    # Verifica se tem algum valor já setado para o nome do WI
    if [ ! -z $work_item ] ; then

      # Verifica se o valor informado é composto inteiramente de números
      if [[ $work_item =~ $re ]] ; then
        return

      # Imprime mensagen de erro para valores inválidos
      else
        echo "'$work_item' é um valor inválido, apenas números são aceitos"
      fi
    fi

    # Solicita que seja informado um valor
    echo 'Informe o número do work item'
    read read_work_item
    work_item=$read_work_item

    _handle_work_item_branch
  }

  _handle_type_branch $type
  _handle_work_item_branch $work_item

  # Chama o operador do git para criar a branch dentro do padrão
  git checkout -b "$type/$work_item"
}

#######################################################

mygit_create_commit() {
  if [[ $1 == '-?' ]] ; then
    echo 'Função para inicializar a operação de commit, formatando o texto do commit'
    echo 'Parâmetros aceitáveis da função -m'
    echo '1º {comment} Comentário breve que será o título do commit, informar entre aspas'
    echo '2º {scope} Informação opcional referente ao escopo da alteração'
    echo '3º {type} Corresponde aos tipos de commits aceitáveis (inferido pelo nome da branch)'
    echo '    CHORE  - Alterações de tarefas de build, automações e pipelines'
    echo '    DOCS   - Adição ou alterações de documentações'
    echo '    FEAT   - Nova funcionalidade ou rotina'
    echo '    FIX    - Correções de bugs'
    echo '    REFACT - Refatoração de código'
    echo '    TEST   - Novo teste automatizado'
    echo '    TYPO   - Corrige erros de digitação ou palavras escritas errado'
    echo '    WIP    - Alterações que ainda não foram terminadas'
    echo 'nº {wi} {wi} Uma sequência de números de issues separadas por espaço (inferido pelo nome da branch)'
    return
  fi

  local title=$1
  local scope=$2

  local type=$3
  local accepted_types=(CHORE, DOCS, FEAT, FIX, REFACT, TEST, TYPO, WIP)

  local work_itens=${*:4} # Atribui todos os valores após a 4 posição
  local work_item_concat=""

  # Captura nome da branch atual
  local current_branch=$(git branch | grep -oP '^\* \K.*')
  local current_branch_array=(${current_branch//// })

  # Função para lidar com o titulo do commit
  _handle_title_commit() {

    # Torna a primeira letra do commit maiúscula
    title=${title^}

    # Verifica se o titulo do commit já foi informado
    if ! [[ -z $title ]] ; then
      return
    fi

    # Solicita que seja informado um valor
    echo 'Informe um título breve para o commit'
    read read_title
    title=$read_title

    _handle_title_commit
  }

  # Função para lidar com o escopo
  _handle_scope_commit() {
     # Torna a primeira letra do escopo commit maiúscula
    scope=${scope^}

    # Verifica se o escopo do commit já foi informado
    if ! [[ -z $scope ]] ; then
      return
    fi

    # Verifica se algum parâmetro foi passado na requsição
    if ! [[ -z $1 ]] ; then
      return
    fi

    # Pergunta se deseja informar um escopo
    echo 'Deseja informar um escopo para esse commit (opcional)'
    read read_scope
    scope=${read_scope^}
  }

  # Função para lidar com o tipo do commit
  _handle_type_commit() {

    # Converte todos os caracteres para maiúsculo
    type=${type^^}
    local re="^${type}, |, ${type}$|, ${type},"

    # Verifica se algum valor válido foi informado
    if [ ! -z $type ] ; then
      if [[ ${accepted_types[@]} =~ $re ]] ; then
        return
      else
        echo "'$type' não é um tipo de commit valido"
      fi
    fi

    # Tenta obter o tipo a partir do nome da branch
    re="^${current_branch_array[0]^^}, |, ${current_branch_array[0]^^}$|, ${current_branch_array[0]^^},"
    if [[ ${accepted_types[@]} =~ $re ]] ; then
      type=${current_branch_array[0]^^}

      # Se o texto do commit não foi informado na execução do comando
      # e um tipo foi inferido, questionar se deseja seguir com valores inferidos
      if [[ -z $1 ]] ; then
        echo "O tipo ${type} foi inferido, presione enter para aceitar ou digite um novo tipo: ${accepted_types[*]}"
        read read_type

        if [ ! -z $read_type ] ; then
          type=${read_type^^}
          _handle_type_commit "$1"
        fi
      fi

      return
    fi

    echo "Informe o tipo de commit: ${accepted_types[*]}"
    read read_type
    type=${read_type^^}

    _handle_type_commit
  }

  # Função para lidar com o numero do work item
  _handle_work_item_commit() {
    local re='^[0-9]+$'

    # Função que percorre a lista de work itens
    __handle_mutiple_work_itens() {
      for wi in $work_itens
      do

        local re_repeat="- #${wi}"$'\n'"|- #${wi}$"

        # Imprime os itens que não são válidos
        if ! [[ $wi =~ $re ]] ; then
          echo "'$wi' não é um número e não pode ser usado como work item"

        # Concatena os itens que são validos
        elif ! [[ $work_item_concat =~ $re_repeat ]] ; then
          work_item_concat+=$'\n'"- #$wi"
        fi

      done
    }

    # Função para solicitar um work item caso nenhum seja encontrado
    __handle_reading_work_item_commit() {

        # Verifica se já foi identificado algum wi
        if ! [[ -z $work_item_concat ]] ; then

          # Se o texto do commit não foi informado na execução do comando
          # e um numero de WI foi inferido, questionar se deseja seguir com valores inferidos
          if [[ -z $1 ]] ; then
            local temp=${work_item_concat//$'\n'- #/, }
            temp=${temp#*, }
            echo "o numero ${temp} foi inferido, presione enter para seguir ou digite uma lista de work itens adicionais"
            read read_work_itens

            if [[ ! -z $read_work_itens[@] ]] ; then
              work_itens=${read_work_itens[@]}

              __handle_mutiple_work_itens
            fi
          fi

          return
        fi

        # Solicita que seja informado um valor
        echo 'Informe a lista de work itens'
        read read_work_itens
        work_itens=${read_work_itens[@]}

        __handle_mutiple_work_itens
        __handle_reading_work_item_commit "$1"
    }

    # Tenta obter o numero do work item pelo nome da branch
    if [[ ${current_branch_array[1]} =~ $re ]] ; then
      work_item_concat=$'\n'"- #${current_branch_array[1]}"
    fi

    __handle_mutiple_work_itens
    __handle_reading_work_item_commit "$1"
  }

  _handle_title_commit
  _handle_scope_commit "$1"
  _handle_type_commit "$1"
  _handle_work_item_commit "$1"

  local text_commit=$"$type($scope): $title"$'\n'"$work_item_concat"

  if [[ -z $scope ]] ; then
    text_commit=$"$type: $title"$'\n'"$work_item_concat"
  fi

  echo "$text_commit"

  # Chama o operado do git para fazer o commit
  git commit -m "$text_commit"
}

#######################################################

mygit_push_origin() {
  if [[ $1 == '-?' ]] ; then
    echo 'Função para inicializar a operação de push das alterações'
    echo 'O comando push origin é realizado com o nome da branch atual'
    return
  fi

  local current_branch=$(git branch | grep -oP '^\* \K.*')

  git push origin $current_branch
}

#######################################################

mygit_helper() {
  echo '-v             Imprime a versão'
  echo '-?             Imprime o menu de ajuda'
  echo '-b             Inicializa a operação de criação de branch'
  echo '-b -?          Lista os parâmetros aceitáveis da função de -b'
  echo '-b {type}      Inicializa a operação de criação de branch passando o tipo'
  echo '-b {type} {wi} Inicializa a operação de criação de branch passando o tipo e número do work item'
  echo '-m             Inicializa a operação de criação de um commit'
  echo '-m -?          Lista os parâmetros aceitáveis da função de -m'
  echo '-m {comment}          Inicializa a operação de criação de um commit passando o comentário'
  echo '-m {comment} {scope}  Inicializa a operação de criação de um commit passando o comentário e escopo'
  echo '-m {comment} {scope} {type}   Inicializa a operação de criação de um commit passando o comentário, escopo e tipo'
  echo '-m {comment} {scope} {type} [{work item list}]          Inicializa a operação de criação de um commit passando o comentário, escopo, tipo e lista de work itens'
}

#######################################################

mygit() {
  local version='1.0.0'
  local command=$1
  shift # Descarta o valor de command do conjunto $*

  # Verifica se recebeu algum comando de entrada
  if [ -z $command ] ; then
    echo 'Nenhum operador informado, use o operador -? para consultar as operações disponíveis'
    return
  fi

  # Imprime a versão do bash
  if [ $command == '-v' ] ; then
    echo $version

  # Imprime as instruções de uso
  elif [ $command == '-?' ] ; then
    mygit_helper

  # Cria uma nova branch
  elif [ $command == '-b' ] ; then
    mygit_create_branch $*

  # Realiza um commit
  elif [ $command == '-m' ] ; then
    mygit_create_commit "$@"

  # Realiza um push origin
  elif [ $command == '-p' ] ; then
    mygit_push_origin

  else
    echo 'Operação inválida, use o operador -? para consultar as operações disponíveis'
  fi
}
