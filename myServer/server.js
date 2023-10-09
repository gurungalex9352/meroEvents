const express = require('express');
const mysqlConnection = require('./conn.js');
const cors = require('cors');

const app = express(); // Initialize the Express app
app.use(cors());

const bodyParser = require('body-parser');
app.use(bodyParser.json());  // Add this line to parse JSON requests

// Define a route to create a new user
app.post('/register', (req, res) => {
  const { fname, lname, username, gender, password } = req.body;
  console.log('Extracted data:', fname, lname, username, gender, password);


  // Ensure all required parameters are provided
  if (!fname || !lname || !username || !gender || !password) {
    return res.status(400).json({ error: 'First name, last name, username, gender, and password are required.' });
  }

  const query = 'INSERT INTO users (fname, lname, username, gender, password) VALUES (?, ?, ?, ?, ?)';
  mysqlConnection.query(query, [fname, lname, username, gender, password], (error, results, fields) => {
    if (error) {
      console.error('Error creating user: ', error);
      return res.status(500).json({ error: 'An error occurred while creating the user.' });
    }
    res.status(201).json({ message: 'User created successfully', userId: results.insertId });
  });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  console.log('Received login request for username:', username, 'and password:', password);

  const query = 'SELECT * FROM users WHERE username = ? AND password = ?';
  mysqlConnection.query(query, [username, password], (error, results) => {
    if (error) {
      console.error('Database error:', error);
      res.status(500).json({ error: 'An error occurred while processing the request.' });
      return;
    }

    console.log('Database query results:', results);

    if (results.length === 1) {
      const user = results[0];
      res.status(200).json({ message: 'Login successful', user });
    } else {
      res.status(400).json({ error: 'Invalid credentials' });
    }
  });
});



app.post('/events', (req, res) => {
  const { event, date } = req.body;

  // Ensure both event and date are provided
  if (!event || !date) {
    return res.status(400).json({ error: 'Event and date are required.' });
  }
  
  const query = 'INSERT INTO events (event, date) VALUES (?, ?)';
  mysqlConnection.query(query, [event, date], (err, result) => {
    if (err) {
      console.error('Error adding event: ', err);
      return res.status(500).json({ error: 'An error occurred while adding the event.' });
    }
    res.status(201).send('Event added successfully.');
  });
});


// Define a route to get all users
app.get('/users', (req, res) => {
    const query = 'SELECT * FROM users';
  
    mysqlConnection.query(query, (error, results, fields) => {
      if (error) {
        console.error('Error fetching users: ', error);
        return res.status(500).json({ error: 'An error occurred while fetching users.' });
      }
  
      // Respond with the fetched user data
      res.status(200).json({ users: results });
    });
  });

  app.get('/events/:date', (req, res) => {
    const date = req.params.date;
    
    const query = 'SELECT * FROM events WHERE date = ?';
    mysqlConnection.query(query, [date], (error, results, fields) => {
      if (error) {
        console.error('Error fetching events: ', error);
        return res.status(500).json({ error: 'An error occurred while fetching events.' });
      }
    
      res.status(200).json({ events: results });
    });
  });  

  app.delete('/events/:id', (req, res) => {
    const eventId = req.params.id;
  
    const query = 'DELETE FROM events WHERE id = ?';
    mysqlConnection.query(query, [eventId], (error, results, fields) => {
      if (error) {
        console.error('Error deleting event: ', error);
        return res.status(500).json({ error: 'An error occurred while deleting the event.' });
      }
  
      res.status(200).json({ message: 'Event deleted successfully.' });
    });
  });
  
  

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
