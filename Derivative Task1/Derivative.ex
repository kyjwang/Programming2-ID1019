defmodule Derivative do

  #@type literal() :: {:num, number()} | {:var, atom()}
  #@type expr() :: {:add, expr(), expr()} | {:mul, expr(), expr()} | literal()

  def testSimple() do
    expression = {:add,{:add,
          {:mul, {:num, 2}, {:var, :x}},
          {:num, 7}
        }, {:num, 9}}
    findDerivative(expression)
  end

  def testExp() do
    expression = {:exp, {:add, {:mul, {:num, 2}, {:var, :x}}, {:num, 3}}, {:num, 3}}
    findDerivative(expression)
  end

  def testDiv() do
    expression = {:div, {:add,{:exp, {:var, :x}, {:num, 2}}, {:num, 4}}, {:add, {:var, :x}, {:num, 6}}}
    findDerivative(expression)
  end

  def testLn() do
    expression = {:ln, {:add,{:exp, {:var, :x}, {:num, 2}}, {:num, 4}}}
    findDerivative(expression)
  end

  def testSin() do
    expression = {:sin, {:add,{:mul, {:var, :x},{:num, -1}}, {:num, 6}}}
    findDerivative(expression)
  end

  def findDerivative(e) do
    derivative = deriv(e, :x)
    IO.write("Expression: #{pprint(e)}\n")
    IO.write("Derivative: #{pprint(derivative)}\n")
    IO.write("Simplified Derivative: #{pprint(simplify(derivative))}\n")
  end

  def deriv({:num, _}, _) do {:num, 0} end
  def deriv({:var, v}, v) do {:num, 1} end
  def deriv({:var, _}, _) do {:num, 0} end
  def deriv({:mul, e1, e2}, v) do
    {:add,
      {:mul, deriv(e1, v), e2},
      {:mul, e1, deriv(e2, v)}
    }
  end
  def deriv({:add, e1, e2}, v) do
    {:add, deriv(e1, v), deriv(e2, v)}
  end
  def deriv({:exp, e1, {:num, n}}, v) do
    {:mul,
      {:mul, {:num, n}, {:exp, e1, {:num, n-1}}},
      deriv(e1, v)
    }
  end
  def deriv({:div, e1, e2}, v) do
    {:div,
      {:add,
        {:mul, deriv(e1, v), e2},
        {:mul, {:num, -1}, {:mul, deriv(e2, v), e1}}
      },
      {:exp, e2, {:num, 2}}
    }
  end
  def deriv({:ln, e1}, v) do
    {:div,
      deriv(e1, v),
      e1
    }
  end
  def deriv({:sin, e1}, v) do
    {:mul,
      deriv(e1, v),
      {:cos, e1}
    }
  end
  def deriv({:cos, e1}, v) do
    {:mul,
      {:num, -1},
      {:mul,
        deriv(e1, v),
        {:sin, e1}
      }
    }
  end

  def simplify({:add, e1, e2}) do
    simplify_add(simplify(e1), simplify(e2))
  end
  def simplify({:mul, e1, e2}) do
    simplify_mul(simplify(e1), simplify(e2))
  end
  def simplify({:exp, e1, e2}) do
    simplify_exp(simplify(e1), e2)
  end
  def simplify({:ln, e}) do
    simplify_ln(simplify(e))
  end
  def simplify({:div, e1, e2}) do
    simplify_div(simplify(e1), simplify(e2))
  end
  def simplify({:sin, e}) do
    simplify_sin(simplify(e))
  end
  def simplify({:cos, e}) do
    simplify_cos(simplify(e))
  end
  def simplify(e) do e end

  def simplify_add({:num, 0}, e2) do e2 end
  def simplify_add(e1, {:num, 0}) do e1 end
  def simplify_add{:num, n1}, {:num, n2} do {:num, n1 + n2} end
  def simplify_add(e1, e2) do {:add, e1, e2} end

  def simplify_mul({:num, 1}, e2) do e2 end
  def simplify_mul(e1, {:num, 1}) do e1 end
  def simplify_mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul(_,{:num, 0}) do {:num, 0} end
  def simplify_mul({:var, v}, {:var, v}) do {:exp, {:var, v}, {:num, 2}} end
  def simplify_mul({:var, v}, {:exp, {:var, v}, {:num, n}}) do {:exp, {:var, v}, {:num, n+1}} end
  def simplify_mul({:exp, {:var, v}, {:num, n}}, {:var, v}) do {:exp, {:var, v}, {:num, n+1}} end
  def simplify_mul({:num, n1}, {:mul, {:num, n2}, e2}) do{:mul, {:num, n1*n2}, e2} end
  def simplify_mul({:num, n1}, {:mul, e2, {:num, n2}}) do {:mul, {:num, n1*n2}, e2} end
  def simplify_mul({:mul, {:num, n1}, e1}, {:num, n2}) do {:mul, {:num, n1*n2}, e1} end
  def simplify_mul({:mul, e1, {:num, n1}}, {:num, n2}) do {:mul, {:num, n1*n2}, e1} end
  def simplify_mul(e1, e2) do {:mul, e1, e2} end

  def simplify_exp(e1, {:num, 1}) do e1 end
  def simplify_exp(_, {:num, 0}) do {:num, 1} end
  def simplify_exp({:num, n}, {:num, m}) do {:num, n ** m} end
  def simplify_exp(e1, e2) do {:exp, e1, e2} end

  def simplify_ln({:num, 1}) do {:num, 0} end
  def simplify_ln({:num, 0}) do {:num, 0} end
  def simplify_ln(e) do {:ln, e} end

  def simplify_div({:num, n1}, {:num, n2}) do {:num, n1 / n2} end
  def simplify_div({:num, 1}, e2) do {:div, {:num, 1}, e2} end
  def simplify_div(e1, {:num, 1}) do e1 end
  def simplify_div(e1, e2) do {:div, e1, e2} end

  def simplify_sin(e) do {:sin, e} end
  def simplify_cos(e) do {:cos, e} end


  def pprint({:num, n}) do "#{n}" end
  def pprint({:var, v}) do "#{v}" end
  def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end
  def pprint({:mul, e1, e2}) do "(#{pprint(e1)} * #{pprint(e2)})" end
  def pprint({:exp, e1, e2}) do "(#{pprint(e1)}) ^ (#{pprint(e2)})" end
  def pprint({:ln, e}) do "ln(#{pprint(e)})" end
  def pprint({:div, e1, e2}) do "(#{pprint(e1)} / #{pprint(e2)})" end
  def pprint({:sin, e}) do "sin(#{pprint(e)})" end
  def pprint({:cos, e}) do "cos(#{pprint(e)})" end
end