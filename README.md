# Swift Vapor Framework POC - Product CRUD Operations with Authentication

## Description
This repository contains a Proof of Concept (POC) project implemented using the Swift Vapor framework. It demonstrates the capabilities of Vapor in building RESTful APIs and handling CRUD operations for a hypothetical Product model.

## Key Features
- **CRUD Operations:** The project includes a complete set of CRUD (Create, Read, Update, Delete) endpoints for managing Product entities. These operations are accessible through the following RESTful routes:
  - `GET /products`: Retrieve a list of all products.
  - `POST /products`: Create a new product.
  - `GET /products/:id`: Retrieve a product by its unique ID.
  - `PUT /products/:id`: Update a product's details by its ID.
  - `DELETE /products/:id`: Remove a product by its ID.

- **Authentication:** To ensure secure access, the project integrates Bearer authentication. This adds a layer of security by requiring a valid token for accessing the API endpoints.

## Objective
The primary goal of this project is to showcase the effectiveness and simplicity of the Swift Vapor framework in building scalable and secure web applications. It's a great starting point for developers interested in exploring Swift for server-side development.

## Usage
- **Open with Xcode:**
  To open the project in Xcode, run the following command in the terminal:
  ```
  vapor xcode
  ```
- **Run with CLI:**
  To run the project using the command line interface, execute:
  ```
  swift run
  ```

Instructions on how to set up, run the project, and test the API endpoints are provided in the documentation.

## Contributions
Feel free to fork this repository, submit issues, and send pull requests to enhance the functionalities or to propose improvements. Your contributions are highly appreciated!!
