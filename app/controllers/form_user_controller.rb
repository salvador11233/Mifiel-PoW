require 'net/http'

class FormUserController < ApplicationController
  def new
  end

  def create
    #Paso 1
    nombre = params[:nombre]
    email = params[:email]

    # Se construye los datos que deseamos enviar a la API
    data = { name: nombre, email: email }

    puts data
    # Realiza la solicitud POST
    response = HTTParty.post('https://candidates.mifiel.com/api/v1/users', body: data.to_json, headers: { 'Content-Type' => 'application/json' })

    # Se guarda la respuesta para su uso posterior
    @response_data = JSON.parse(response.body)

    puts "Respuesta paso 1 #{@response_data}"
  
    #Paso 2
    # Se obtiene el parámetro next_challenge.challenge de la respuesta del Paso 1
    challenge = @response_data['next_challenge']['challenge']

    # Se aplica la función hash SHA-256 al challenge
    hash_result = Digest::SHA256.hexdigest(challenge)

    # Los datos para el cuerpo de la solicitud PUT
    data = { result: hash_result }

    # Se realiza la solicitud PUT a la API
    response = HTTParty.put("https://candidates.mifiel.com/api/v1/users/#{@response_data['id']}/challenge/digest", body: data.to_json, headers: { 'Content-Type' => 'application/json' })

    # Guardamos la respuesta
    @response_data_paso2 = JSON.parse(response.body)

    puts "Respuesta paso 2 #{@response_data_paso2}"

    #Paso 3
    # Se obtiene la dificultad objetivo del Paso 2
    difficulty = @response_data_paso2['next_challenge']['difficulty']

    #  Se obtiene el challenge del Paso 2
    challenge = @response_data_paso2['next_challenge']['challenge']

    # Algoritmo PoW para encontrar el nonce
    nonce = calcular_nonce(challenge, difficulty)

    # Los datos para el cuerpo de la solicitud PUT
    data = { result: nonce }

    # Se realiza la solicitud PUT a la API
    response = HTTParty.put("https://candidates.mifiel.com/api/v1/users/#{@response_data['id']}/challenge/pow", body: data.to_json, headers: { 'Content-Type' => 'application/json' })

    # Guardamos la respuesta
    @response_data_paso3 = JSON.parse(response.body)

    puts "Respuesta paso 3 #{@response_data_paso3}"
  end

  private

  def calcular_nonce(challenge, difficulty)
    # Inicializa el nonce en 0
    nonce = 0
    target = '0' * difficulty  # Dificultad objetivo 
  
    loop do
      # Combina el challenge y el nonce
      data = "#{challenge}#{nonce}"
  
      # Calcula el hash SHA-256 del data
      hash = Digest::SHA256.hexdigest(data)
  
      # Compara los primeros caracteres con la dificultad objetivo
      if hash[0, difficulty] == target
        # Si cumple con la dificultad, se ha encontrado un nonce válido
        return nonce
      end
  
      # Incrementa el nonce y sigue buscando
      nonce += 1
    end
  end
end
