import pytest
from calculadora import Calculadora

def test_somar():
    calc = Calculadora()
    assert calc.somar(5, 3) == 8

def test_subtrair():
    calc = Calculadora()
    assert calc.subtrair(10, 4) == 6

def test_multiplicar():
    calc = Calculadora()
    assert calc.multiplicar(3, 7) == 21

def test_dividir():
    calc = Calculadora()
    assert calc.dividir(20, 4) == 5

def test_dividir_por_zero():
    calc = Calculadora()
    with pytest.raises(ValueError, match="Divisão por zero não permitida"):
        calc.dividir(10, 0)
