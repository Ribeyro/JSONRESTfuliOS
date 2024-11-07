//
//  ViewController.swift
//  JSONRESTful
//
//  Created by Ribeyro Guzman on 6/11/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    // Declaramos `users` como una propiedad de clase
    var users: [Users] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validarUsuario(ruta: String, completed: @escaping () -> Void) {
        
        // Validación de la URL
        guard let url = URL(string: ruta) else {
            print("URL inválida")
            return
        }
        
        // Inicia la solicitud de red
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                do {
                    self.users = try JSONDecoder().decode([Users].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error en JSON: \(error)")
                }
            } else {
                print("Error en la solicitud: \(error!)")
            }
        }.resume() // Mover `resume()` fuera del bloque `do-catch`
    }

    @IBAction func logear(_ sender: Any) {
        let ruta = "http://localhost:3000/usuarios?"
        let usuario = txtUsuario.text ?? ""
        let contrasena = txtContrasena.text ?? ""
        let url = ruta + "nombre=\(usuario)&clave=\(contrasena)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        
        validarUsuario(ruta: crearURL) {
            if self.users.isEmpty {
                print("Nombre de usuario y/o contraseña incorrectos")
            } else {
                print("Logueo exitoso")
                self.performSegue(withIdentifier: "segueLogeo", sender: nil)
                for data in self.users {
                    print("id:\(data.id), nombre:\(data.nombre), email: \(data.email)")
                }
            }
        }
    }
}
