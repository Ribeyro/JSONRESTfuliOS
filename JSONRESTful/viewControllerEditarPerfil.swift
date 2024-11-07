import UIKit

class viewControllerEditarPerfil: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    @IBOutlet weak var txtEmail: UITextField!

    var usuario: Users? // Objeto para almacenar los datos del usuario

    override func viewDidLoad() {
        super.viewDidLoad()

        // Carga los datos del usuario si están disponibles
        if let usuario = usuario {
            txtNombre.text = usuario.nombre
            txtClave.text = usuario.clave
            txtEmail.text = usuario.email
        }
    }

    @IBAction func guardarPerfilTapped(_ sender: UIButton) {
        guard let nombre = txtNombre.text,
              let clave = txtClave.text,
              let email = txtEmail.text else { return }
        
        // Crear diccionario con los datos actualizados
        let datosActualizados = ["nombre": nombre, "clave": clave, "email": email]
        
        // Llamar al método para actualizar en el servidor
        if let usuarioId = usuario?.id {
            actualizarUsuarioEnServidor(id: usuarioId, datos: datosActualizados)
        }
    }

    func actualizarUsuarioEnServidor(id: Int, datos: [String: Any]) {
        let ruta = "http://localhost:3000/usuarios/\(id)"
        guard let url = URL(string: ruta) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: .prettyPrinted)
        } catch {
            print("Error al serializar los datos: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud de actualización: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        task.resume()
    }
}
