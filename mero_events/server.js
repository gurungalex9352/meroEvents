const express = require('express');
const mysqlConnection = require('con.js');

const app = express(); // Initialize the Express app

const bodyParser = require('body-parser');
app.use(bodyParser.json());  // Add this line to parse JSON requests

// Define a route to create a new user
// app.post('/api/users', (req, res) => {
//     const { name, email, password } = req.body;
    
//     // Ensure all required parameters are provided
//     if (!name || !email || !password) {
//       return res.status(400).json({ error: 'Name, email, and password are required.' });
//     }
  
//     const query = 'INSERT INTO user (name, email, password) VALUES (?, ?, ?)';
//     mysqlConnection.query(query, [name, email, password], (error, results, fields) => {
//       if (error) {
//         console.error('Error creating user: ', error);
//         return res.status(500).json({ error: 'An error occurred while creating the user.' });
//       }
//       res.status(201).json({ message: 'User created successfully', userId: results.insertId });
//     });
//   });