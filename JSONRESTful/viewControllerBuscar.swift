import UIKit

class viewControllerBuscar: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var peliculas = [Peliculas]()
    var usuarios = [Users]()
    
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
        
        // Cargar datos de usuarios
        let rutaUsuarios = "http://localhost:3000/usuarios/"
        
        cargarUsuarios(ruta: rutaUsuarios)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero : \(peliculas[indexPath.row].genero) Duracion :  \(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    // Acción del botón buscar
    @IBAction func btnBuscar(_ sender: Any) {
        buscarPelicula()
    }
    
    func buscarPelicula() {
        guard let nombreBuscado = txtBuscar.text, !nombreBuscado.isEmpty else {
            mostrarAlerta(mensaje: "Por favor, ingrese el nombre de una película.")
            return
        }
        
        let peliculaEncontrada = peliculas.contains { $0.nombre.lowercased() == nombreBuscado.lowercased() }
        
        if peliculaEncontrada {
            mostrarAlerta(mensaje: "¡La película '\(nombreBuscado)' fue encontrada!")
        } else {
            mostrarAlerta(mensaje: "La película '\(nombreBuscado)' no se encontró.")
        }
    }
    
    // Función para mostrar la alerta
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Resultado de la búsqueda", message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accionAceptar)
        present(alerta, animated: true, completion: nil)
    }
    
    func cargarPeliculas(ruta: String, completed: @escaping () -> Void) {
        let url = URL(string: ruta)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error al decodificar JSON")
                }
            }
        }.resume()
    }
    
    // Función para cargar usuarios desde el servidor
    func cargarUsuarios(ruta: String) {
        guard let url = URL(string: ruta) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                do {
                    self.usuarios = try JSONDecoder().decode([Users].self, from: data!)
                } catch {
                    print("Error al decodificar JSON de usuarios: \(error)")
                }
            }
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Preparar para la transición a la pantalla de edición de película
        if segue.identifier == "segueEditar" {
            let siguienteVC = segue.destination as! viewControllerAgregar
            siguienteVC.pelicula = sender as? Peliculas
        }
        
        // Preparar para la transición a la pantalla de edición de perfil
        if segue.identifier == "segueEditarPerfil" {
            let destinoVC = segue.destination as! viewControllerEditarPerfil
            destinoVC.usuario = obtenerUsuarioActual()
        }
    }

    
    // Implementación del editingStyle para eliminar una película con confirmación
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Obtener la película seleccionada
            let peliculaAEliminar = peliculas[indexPath.row]
            
            // Crear una alerta de confirmación
            let alerta = UIAlertController(title: "Eliminar Película", message: "¿Está seguro de que desea eliminar la película '\(peliculaAEliminar.nombre)'?", preferredStyle: .alert)
            
            // Acción "SI" para confirmar la eliminación
            let accionEliminar = UIAlertAction(title: "Sí", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Eliminar la película de la fuente de datos
                self.peliculas.remove(at: indexPath.row)
                
                // Eliminar la película de la tabla con animación
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                // Aquí puedes agregar el código para eliminar en el servidor (si aplica)
                // Por ejemplo: self.eliminarPeliculaEnServidor(id: peliculaAEliminar.id)
            }
            
            // Acción "NO" para cancelar la eliminación
            let accionCancelar = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            // Agregar acciones a la alerta
            alerta.addAction(accionEliminar)
            alerta.addAction(accionCancelar)
            
            // Presentar la alerta
            present(alerta, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func editarPerfilTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "segueEditarPerfil", sender: nil)
    }
    
    
    // Obtener el usuario actual
    func obtenerUsuarioActual() -> Users? {
        return usuarios.first { $0.id == 1 } // Cambia `1` al ID del usuario logeado
    }
}

