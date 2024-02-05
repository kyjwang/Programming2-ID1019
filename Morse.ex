defmodule Decode do

  def decode(input) do
    table = decode_table()
    decode(input, table, [])
  end

  def decode([], _, acc) do Enum.reverse(acc) end
  def decode(input, table , acc) do
    {char, rest} = decode_char(input,table)
    decode(rest, table,[char|acc])
  end

  def decode_table() do
    Morse.morse()
  end

  def decode_char(input) do
    table = decode_table()
    decode_char(input,table)
  end
  def decode_char([],{:node, char, _, _}) do {char,[]} end

  def decode_char([?-|input], {:node, _, long, _}) do
    decode_char(input, long)
  end
  def decode_char([?.| input], {:node, _,_, short}) do
    decode_char(input,short)
  end

  def decode_char([?\s|input], {:node,:na , _, _ }) do
  {?*,input}
  end
  def decode_char([?\s|input], {:node,char , _, _ }) do
    {char,input}
  end

end

defmodule Encode do

  def encode(text) do
    encode(text,encode_table(),[])
  end
  def encode([],_, coded) do Enum.reverse(coded) end
  def encode([char|text],table, sofar) do
  encode(text,table, encode_lookup(char, table) ++[32] ++ sofar)
  end

  def codes(:nil, _) do [] end
  def codes({:node,:na, long,short},code) do
    codes(long,[?-|code]) ++ codes(short,[?.|code])
  end
  def codes({:node,char,long,short},code) do
    [{char,code}]++ codes(long,[?-|code]) ++ codes(short,[?.|code])
  end

  def encode_lookup(char,[{char, code} | _]) do code  end
  def encode_lookup(char,[_ | rest]) do encode_lookup(char,rest) end
  def encode_lookup(char, map) do Map.get(map, char) end

  def encode_table() do
    codes = codes(Morse.morse(),[])
    Enum.reduce(codes, %{},fn({char,code },acc) -> Map.put(acc,char,code)end)
  end

  # existing code
  def encode_name(name) do
    name
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.map(&encode_lookup(&1, encode_table()))
    |> List.flatten()
  end

  defp codes do
    [{32, '..--'},
     {37,'.--.--'},
     {44,'--..--'},
     {45,'-....-'},
     {46,'.-.-.-'},
     {47,'.-----'},
     {48,'-----'},
     {49,'.----'},
     {50,'..---'},
     {51,'...--'},
     {52,'....-'},
     {53,'.....'},
     {54,'-....'},
     {55,'--...'},
     {56,'---..'},
     {57,'----.'},
     {58,'---...'},
     {61,'.----.'},
     {63,'..--..'},
     {64,'.--.-.'},
     {97,'.-'},
     {98,'-...'},
     {99,'-.-.'},
     {100,'-..'},
     {101,'.'},
     {102,'..-.'},
     {103,'--.'},
     {104,'....'},
     {105,'..'},
     {106,'.---'},
     {107,'-.-'},
     {108,'.-..'},
     {109,'--'},
     {110,'-.'},
     {111,'---'},
     {112,'.--.'},
     {113,'--.-'},
     {114,'.-.'},
     {115,'...'},
     {116,'-'},
     {117,'..-'},
     {118,'...-'},
     {119,'.--'},
     {120,'-..-'},
     {121,'-.--'},
     {122,'--..'}]
  end

end



defmodule Morse do
  @moduledoc """
  Documentation for `Morse`.
  """

  @doc """
  Hello world.
  ## Examples
      iex> Morse.hello()
      :world
  """
  def hello do
    :world
  end
  def base(), do: '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ...'

  def rolled(), do: '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .----'


  def name() do
    "LUCAS"
  end

  def solution() do
    IO.puts(Decode.decode(base()))
    Decode.decode(rolled())
    ##IO.puts(Encode.encode(name))
    ##Encode.encode(name())
  end

  def morse() do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
      {:node, 50, nil, nil},
      {:node, :na, nil, {:node, 63, nil, nil}}},
    {:node, 102, nil, nil}},
  {:node, 115,
    {:node, 118, {:node, 51, nil, nil}, nil},
    {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

end
