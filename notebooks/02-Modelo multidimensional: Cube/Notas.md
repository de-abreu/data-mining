# Cláusulas de Agregação: `GROUP BY`, `ROLLUP` e `CUBE`

As cláusulas `CUBE` e `ROLLUP` consistem em extensões à cláusula `GROUP BY`
disponíveis no dialeto `posgreSQL`. Enquanto `GROUP BY` permite um único nível
de agregação, as duas primeiras permitem múltiplas agregações organizadas entre
si por níveis hierárquicos.

Imagine possuir um BD acerca das vendas de uma empresa ou conglomerado
multinacional. Com os dados sendo organizados em termos de territórios
geográficos, busca-se obter para um dado período qualquer:

- Vendas obtidas em cada cidade (sendo este o nível mais detalhado);
- Vendas obtidas em cada país;
- Vendas obtidas em cada região ou continente
- Vendas obtidas no total (internacionalmente)

## `ROLLUP`

O `ROLLUP` cria subtotais do nível de maior a menor detalhes, **movendo-se da
direita para a esquerda** em uma lista de colunas.

### Sintaxe

```sql
SELECT col1, col2, aggregate_function(col3)
FROM table_name
GROUP BY ROLLUP (col1, col2);
```

### Como funciona

Cria-se agregados para todas as combinações de grupos por colunas
hierarquicamente:

1. `(col1, col2)`: O mesmo resultado que a aplicação direta do `GROUP BY`
2. `(col1)`: Subtotal para cada `col1`, tal qual `col2` fosse combinado
   (`rolled up`) a este.
3. `()` Total geral, como se `col1` e `col2` fossem combinados.

### Exemplo

Considere a seguinte tabela `sales_data`:

| region        | country | sales |
| :------------ | :------ | ----: |
| North America | USA     |   100 |
| North America | USA     |    50 |
| North America | Canada  |    75 |
| Europe        | Germany |   200 |
| Europe        | France  |   125 |

e a seguinte consulta:

```sql
SELECT
    region,
    country,
    SUM(sales) as total_sales
FROM sales_data
GROUP BY ROLLUP (region, country)
ORDER BY region, country;
```

O resultado será:

| region        | country | total_sales | Observação (não figura na tabela)   |
| :------------ | :------ | ----------: | :---------------------------------- |
| Europe        | France  |         125 |                                     |
| Europe        | Germany |         200 |                                     |
| Europe        | `null`  |         325 | <- Subtotal para a Europa           |
| North America | Canada  |          75 |                                     |
| North America | USA     |         150 |                                     |
| North America | `null`  |         225 | <- Subtotal para a América do Norte |
| `null`        | `null`  |         550 | <- Total geral                      |

### Conclusão

O `ROLLUP` é uma ferramenta adequada a análise de dados os quais possuem entre
si uma relação hierárquica. Note que a ordem das colunas em passadas entre
parênteses a `ROLLUP()` altera o resultado deste.

## Cláusula `CUBE`

Por vez, `CUBE` vai mais além e gera todas as possíveis combinações de
agrupamentos.

### Sintaxe

```sql
SELECT col1, col2, aggregate_function(col3)
FROM table_name
GROUP BY CUBE (col1, col2);
```

### Como funciona

Para um par de colunas, `CUBE(a, b)` gera os agrupamentos:

1. `(a, b)`
2. `(a)`
3. `(b)`
4. `()`

### Exemplo

Considerada a mesma tabela anterior, para

```sql
SELECT
    region,
    country,
    SUM(sales) as total_sales
FROM sales_data
GROUP BY ROLLUP (region, country)
ORDER BY region, country;

```

obtêm-se

| region        | country | total_sales | Observação (não figura na tabela)             |
| :------------ | :------ | ----------: | :-------------------------------------------- |
| Europe        | France  |         125 |                                               |
| Europe        | Germany |         200 |                                               |
| Europe        | `null`  |         325 | <- Subtotal para a Europa                     |
| North America | Canada  |          75 |                                               |
| North America | USA     |         150 |                                               |
| North America | `null`  |         225 | <- Subtotal para a América do Norte           |
| `null`        | Canada  |          75 | <- Subtotal para o Canada em todas as regiões |
| `null`        | France  |         125 |                                               |
| `null`        | Germany |         200 |                                               |
| `null`        | USA     |         150 |                                               |
| `null`        | `null`  |         550 | <- Total geral                                |

### Conclusão

O `CUBE` é adequado a análises entre tabelas onde se busca obter subtotais em
todas as dimensões, e não de apenas uma única hierarquia. Esta é uma ferramenta
poderosa mas propensa a poluição pois gera um número de colunas
significativamente maior que `GROUP BY` sozinho ou com o uso de `ROLLUP`.

### Lidando com `NULL`s

Valores `NULL` são gerados como _placeholders_ nestes métodos de agregação, o
que pode ser problemático se os dados sendo analisados possuem valores nulos
legítimos. Uma solução para tal é o uso da função `GROUPING`, a qual retorna 1
ou 0 a depender se o `NULL` em questão foi, ou não, gerado pelo agrupamento.

Por exemplo, com o uso de `GROUPING` a seguir

```sql
SELECT
    CASE WHEN GROUPING(region) = 1 THEN 'All Regions' ELSE region END AS region,
    CASE WHEN GROUPING(country) = 1 THEN 'All Countries' ELSE country END AS country,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY ROLLUP (region, country)
ORDER BY region, country;
```

A tabelas para `ROLLUP` fica:

| region        | country       | total_sales | Observação (não figura na tabela)   |
| :------------ | :------------ | ----------: | :---------------------------------- |
| Europe        | France        |         125 |                                     |
| Europe        | Germany       |         200 |                                     |
| Europe        | All Countries |         325 | <- Subtotal para a Europa           |
| North America | Canada        |          75 |                                     |
| North America | USA           |         150 |                                     |
| North America | All Countries |         225 | <- Subtotal para a América do Norte |
| All Regions   | All Countries |         550 | <- Total geral                      |
