//
//  viewControllerAgregar.swift
//  JSONRESTful
//
//  Created by Ribeyro Guzman on 6/11/24.
//

import UIKit

class viewControllerAgregar: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtGenero: UITextField!
    @IBOutlet weak var txtDuracion: UITextField!
    @IBOutlet weak var botonGuardar: UIButton!
    @IBOutlet weak var botonActualizar: UIButton!
    
    var pelicula: Peliculas? // Variable para almacenar la información de la película seleccionada

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pelicula == nil {
            botonGuardar.isEnabled = true
            botonActualizar.isEnabled = false
        } else {
            botonGuardar.isEnabled = false
            botonActualizar.isEnabled = true
            txtNombre.text = pelicula!.nombre
            txtGenero.text = pelicula!.genero
            txtDuracion.text = pelicula!.duracion
        }
    }
    
    func metodoPOST(ruta: String, datos: [String: Any]) {
        guard let url = URL(string: ruta) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: .prettyPrinted)
        } catch {
            print("Error al serializar JSON: \(error)")
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud: \(error)")
                return
            }
            
            guard let data = data else {
                print("No se recibió respuesta de datos")
                return
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print(dict)
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }
        task.resume()
    }

    func metodoPUT(ruta: String, datos: [String: Any]) {
        guard let url = URL(string: ruta) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: .prettyPrinted)
        } catch {
            print("Error al serializar JSON: \(error)")
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud: \(error)")
                return
            }
            
            guard let data = data else {
                print("No se recibió respuesta de datos")
                return
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print(dict)
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }
        task.resume()
    }

    @IBAction func btnGuardar(_ sender: Any) {
        let nombre = txtNombre.text!
        let genero = txtGenero.text!
        let duracion = txtDuracion.text!
        let datos = ["usuarioId": 1, "nombre": "\(nombre)", "genero": "\(genero)", "duracion": "\(duracion)"] as [String : Any]
        
        let ruta = "http://localhost:3000/peliculas/"
        
        metodoPOST(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActualizar(_ sender: Any) {
        guard let pelicula = pelicula else { return }
        
        let nombre = txtNombre.text!
        let genero = txtGenero.text!
        let duracion = txtDuracion.text!
        let datos = ["usuarioId": 1, "nombre": "\(nombre)", "genero": "\(genero)", "duracion": "\(duracion)"] as [String : Any]
        
        let ruta = "http://localhost:3000/peliculas/\(pelicula.id)" // Ruta con el ID de la película para actualizar
        
        metodoPUT(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
}
