mygit_create_branch() {
  if [[ $1 == '-?' ]] ; then
    echo 'mygit helper'
    echo 'Função para inicializar a operação de criação de branchs'
    echo 'Parâmetros aceitáveis da função -b'
    echo '1º {type} Corresponde aos tipos de branchs aceitáveis'
    echo '    US - User Story'
    echo '2º {wi} Corresponde ao numero da issue'
    return
  fi

  local type=$1
  local work_item=$2
  local accepted_types=("US")

  # Função que lida com a escolha do tipo da branch
  _handle_type_branch() {

    # Converte todos os caracteres para maiúsculo
    type=${type^^}

    # Verifica se possui algum valor preenchido
    if [ ! -z $type ] ; then

      # Verifica se o valor preenchido é valido
      if [[ ${accepted_types[*]} =~ ${type} ]] ; then
        return

      # Imprime mensagem de erro para valores inválidos
      else
        echo "'$type' não é um tipo valido"
      fi
    fi

    # Solicita que seja informado um valor
    printf 'Informe um dos seguintes tipos: '
    printf '%s ' "${accepted_types[@]}"
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
    echo -n 'Informe o número do work item: '
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
    echo 'mygit helper'
    echo 'Função para inicializar a operação de commit, formatando o texto do commit'
    echo 'Parâmetros aceitáveis da função -m'
    echo '1º {comment} Comentário breve que será o titulo do commit, informar entre aspas'
    echo '2º {type} Corresponde aos tipos de commits aceitáveis'
    echo '    US  - User Story'
    echo '    WIP - Work in progess'
    echo 'nº {wi} {wi} Uma sequencia de numeros de issues separadas por espaço'
    return
  fi

  local title=$1

  local type=$2
  local accepted_types=("US", "WIP")

  shift # Descarta $1
  shift # Descarta $2
  local work_itens=$@ # Atribui todos os valores restantes
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
    echo -n 'Informe um titulo breve para o commit: '
    read read_title
    title=$read_title

    _handle_title_commit
  }

  # Função para lidar com o tipo do commit
  _handle_type_commit() {

    # Converte todos os caracteres para maiúsculo
    type=${type^^}

    # Verifica se algum valor válido foi informado
    if [ ! -z $type ] ; then
      if [[ ${accepted_types[*]} =~ ${type} ]] ; then
        return
      else
        echo "'$type' não é um tipo de commit valido"
      fi
    fi

    # Tenta obter o tipo a partir do nome da branch
    if [[ ${accepted_types[*]} =~ ${current_branch_array[0]^^} ]] ; then
      type=${current_branch_array[0]^^}
      return
    fi

    printf "Informe o tipo de commit: "
    printf '%s ' "${accepted_types[@]}"
    read read_type
    type=${read_type^^}

    _handle_type_commit
  }

  # Função para lidar com o numero do work item
  _handle_work_item_commit() {
    local re='^[0-9]+$'

    # Tenta obter o numero do work item pelo nome da branch
    if [[ ${current_branch_array[1]} =~ $re ]] ; then
      work_item_concat="$work_item_concat #${current_branch_array[1]}"
    fi

    # Percorre a lista de parâmetros
    for wi in $work_itens
    do

      # Imprime os itens que não são válidos
      if ! [[ $wi =~ $re ]] ; then
        echo "'$wi' não é um número e não pode ser usado como work item"

      # Concatena os itens que são validos
      elif ! [[ $work_item_concat == *$wi* ]] ; then
        work_item_concat="$work_item_concat #$wi"
      fi

    done

    # Função para solicitar um work item caso nenhum seja encontrado
    _handle_reading_work_item_commit() {

      # Confirma se não ha nenhum valor valido contabilizado
      if [[ -z $work_item_concat ]] ; then
        echo -n 'Informe um numero de work item: '
        read read_work_item
        work_item_concat=$read_work_item

        # Mantem a recursividade do metodo caso não nada seja informado
        if [[ -z $work_item_concat ]] ; then
          _handle_reading_work_item_commit

        # Valida se o valor informado é um work item valido
        elif ! [[ $work_item_concat =~ $re ]] ; then
          echo "'$work_item_concat' não é um numero e não pode ser usado como work item"
          work_item_concat=''
          _handle_reading_work_item_commit

        # Acrescenta '#' na frente do work item
        else
          work_item_concat="#$work_item_concat"
        fi
      fi
    }

    _handle_reading_work_item_commit
  }

  _handle_title_commit
  _handle_type_commit
  _handle_work_item_commit

  echo "($type) $work_item_concat - $title"

  # Chama o operado do git para fazer o commit
  git commit -m "($type) $work_item_concat - $title"
}

#######################################################

mygit_helper() {
  echo 'mygit helper'
  echo '-v             Imprime a versão'
  echo '-?             Imprime o menu de ajuda'
  echo '-b             Inicializa a operação de criação de branch'
  echo '-b -?          Lista os parâmetros aceitáveis da função de -b'
  echo '-b {type}      Inicializa a operação de criação de branch passando o tipo'
  echo '-b {type} {wi} Inicializa a operação de criação de branch passando o tipo e numero do work item'
  echo '-m             Inicializa a operação de criação de um commit'
  echo '-m -?          Lista os parâmetros aceitáveis da função de -m'
  echo '-m {comment}          Inicializa a operação de criação de um commit passando o comentário'
  echo '-m {comment} {type}   Inicializa a operação de criação de um commit passando o comentário e tipo'
  echo '-m {comment} {type} [{work item list}]          Inicializa a operação de criação de um commit passando o comentário, tipo e lista de work itens'
}

#######################################################

mygit() {
  local version='1.0.0'
  local command=$1
  shift # Descarta o valor de command do conjunto $*

  # Verifica se recebeu algum comando de entrada
  if [ -z $command ] ; then
    echo 'Nenhum operador informado, use mygit -? para consultar as operações disponíveis'
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
    local temp_title=$1
    shift # Descarta segundo valor do conjunto, texto
    mygit_create_commit "$temp_title" $*

  else
    echo 'Operação inválida, use mygit -? para consultar as operações disponíveis'
  fi

}