# 📚 Operadores Lógicos y Relacionales en MongoDB

Este repositorio contiene una colección en formato JSON con **operadores lógicos**, **relacionales** y **combinaciones entre ellos** para facilitar su consulta, estudio y prueba en MongoDB.

## ✅ Contenido

- **Operadores Lógicos** → `tipo: "lógico"`
- **Operadores Relacionales** → `tipo: "relacional"`
- **Combinaciones** → `tipo: "combinado"`

---

## 📌 Cómo Consultar

A continuación te muestro ejemplos de cómo consultar desde la consola de MongoDB (`mongosh`) o desde cualquier herramienta compatible como MongoDB Compass.

---

## 🔎 Consultar por tipo

```js
// Consultar operadores lógicos
db.operadores.find({ tipo: "lógico" })

// Consultar operadores relacionales
db.operadores.find({ tipo: "relacional" })

// Consultar combinaciones de operadores
db.operadores.find({ tipo: "combinado" })

// Buscar una combinación específica por nombre
db.operadores.find({ nombre: "and_or_eq_gt" })
