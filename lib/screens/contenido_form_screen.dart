import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import '../services/camara_service.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';
import '../widgets/guide_image.dart';

class ContenidoFormScreen extends StatefulWidget {
  const ContenidoFormScreen({
    required this.categoria,
    this.contenido,
    this.repository,
    super.key,
  });

  final TipoContenido categoria;
  final Contenido? contenido;
  final ContenidoRepository? repository;

  @override
  State<ContenidoFormScreen> createState() => _ContenidoFormScreenState();
}

class _ContenidoFormScreenState extends State<ContenidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _precioController = TextEditingController();
  final _tipoPlatoController = TextEditingController();
  final CamaraService _cameraService = CamaraService();

  late TipoContenido _categoria;
  String? _distrito;
  DateTime? _fecha;
  String? _nombreError;
  bool _guardando = false;
  String? _errorGeneral;
  String? _selectedImagePath;

  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();

  bool get _esEdicion => widget.contenido != null;

  @override
  void initState() {
    super.initState();
    _categoria = widget.contenido?.tipoContenido ?? widget.categoria;
    _selectedImagePath = widget.contenido?.rutaImagen;
    _precargarCampos(widget.contenido);
  }

  void _precargarCampos(Contenido? contenido) {
    if (contenido == null) return;
    _nombreController.text = contenido.nombre;
    _descripcionController.text = contenido.descripcion;
    switch (contenido) {
      case Lugar value:
        _distrito = value.distrito;
        _latitudController.text = value.latitud?.toString() ?? '';
        _longitudController.text = value.longitud?.toString() ?? '';
      case Festividad value:
        _distrito = value.distrito;
        _fecha = DateTime(2024, value.mes, value.dia);
      case Plato value:
        _precioController.text = value.precioRef?.toString() ?? '';
        _tipoPlatoController.text = value.tipo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _precioController.dispose();
    _tipoPlatoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(FormFieldState<DateTime> field) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Seleccione la fecha de la festividad',
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() => _fecha = picked);
    field.didChange(picked);
  }

  Future<void> _seleccionarImagen() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar fotografía'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;
    try {
      final savedPath = await _cameraService.elegirYGuardar(source);
      if (!mounted || savedPath == null) return;
      setState(() {
        _selectedImagePath = savedPath;
        _errorGeneral = null;
      });
    } catch (_) {
      if (!mounted) return;
      final hint = source == ImageSource.camera
          ? 'No se pudo abrir la cámara. Intente elegir una fotografía de la galería.'
          : 'No se pudo guardar la fotografía. Inténtelo nuevamente.';
      setState(() => _errorGeneral = hint);
    }
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _guardando = true;
      _nombreError = null;
      _errorGeneral = null;
    });

    try {
      final exists = await _repository.existeNombre(
        _categoria,
        _nombreController.text,
        excluirId: widget.contenido?.id,
      );
      if (!mounted) return;
      if (exists) {
        setState(() {
          _nombreError = 'Ya existe un contenido con ese nombre.';
          _guardando = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      final content = _buildContent();
      if (_esEdicion) {
        await _repository.actualizar(content);
      } else {
        final id = await _repository.insertar(content);
        if (!mounted) return;
        final saved = await _repository.obtenerPorId(_categoria, id);
        if (!mounted) return;
        if (saved == null) {
          throw StateError('No se encontró el contenido después de guardarlo.');
        }
        Navigator.pop<Contenido>(context, saved);
        return;
      }

      if (!mounted) return;
      Navigator.pop<Contenido>(context, content);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _errorGeneral =
            'No se pudo guardar. Revise los datos e inténtelo nuevamente.';
      });
    }
  }

  Contenido _buildContent() {
    final now = DateTime.now();
    final createdAt = widget.contenido?.creadoEn ?? now;
    final name = _nombreController.text.trim();
    final description = _descripcionController.text.trim();
    final imagePath = _selectedImagePath;
    switch (_categoria) {
      case TipoContenido.lugar:
        return Lugar(
          id: widget.contenido?.id,
          nombre: name,
          distrito: _distrito!,
          descripcion: description,
          latitud: _parseOptionalDouble(_latitudController.text),
          longitud: _parseOptionalDouble(_longitudController.text),
          rutaImagen: imagePath,
          creadoEn: createdAt,
        );
      case TipoContenido.festividad:
        final date = _fecha!;
        return Festividad(
          id: widget.contenido?.id,
          nombre: name,
          mes: date.month,
          dia: date.day,
          descripcion: description,
          distrito: _distrito,
          rutaImagen: imagePath,
          creadoEn: createdAt,
        );
      case TipoContenido.plato:
        return Plato(
          id: widget.contenido?.id,
          nombre: name,
          descripcion: description,
          precioRef: _parseOptionalDouble(_precioController.text),
          tipo: _tipoPlatoController.text.trim(),
          rutaImagen: imagePath,
          creadoEn: createdAt,
        );
    }
  }

  double? _parseOptionalDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.parse(text.replaceAll(',', '.'));
  }

  String get _categoryLabel => switch (_categoria) {
    TipoContenido.lugar => 'Lugar',
    TipoContenido.festividad => 'Festividad',
    TipoContenido.plato => 'Plato',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar $_categoryLabel' : 'Nuevo $_categoryLabel',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FormField<TipoContenido>(
                    initialValue: _categoria,
                    validator: Validadores.categoria,
                    builder: (field) => InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        errorText: field.errorText,
                        border: const OutlineInputBorder(),
                      ),
                      child: SegmentedButton<TipoContenido>(
                        segments: const [
                          ButtonSegment(
                            value: TipoContenido.lugar,
                            label: Text('Lugar'),
                            icon: Icon(Icons.place_outlined),
                          ),
                          ButtonSegment(
                            value: TipoContenido.festividad,
                            label: Text('Fiesta'),
                            icon: Icon(Icons.celebration_outlined),
                          ),
                          ButtonSegment(
                            value: TipoContenido.plato,
                            label: Text('Platos'),
                            icon: Icon(Icons.restaurant_outlined),
                          ),
                        ],
                        selected: {_categoria},
                        onSelectionChanged: _esEdicion
                            ? null
                            : (selection) {
                                final selected = selection.first;
                                setState(() {
                                  _categoria = selected;
                                  _distrito = null;
                                  _fecha = null;
                                  _nombreError = null;
                                });
                                field.didChange(selected);
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nombreController,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ingrese un nombre de 4 a 80 caracteres',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _nombreError ?? Validadores.nombre(value),
                    onChanged: (_) {
                      if (_nombreError != null) {
                        setState(() => _nombreError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describa el contenido en 25 a 500 caracteres',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: Validadores.descripcion,
                  ),
                  if (_categoria != TipoContenido.plato) ...[
                    const SizedBox(height: 16),
                    _buildDistrictField(),
                  ],
                  if (_categoria == TipoContenido.festividad) ...[
                    const SizedBox(height: 16),
                    _buildDateField(),
                  ],
                  if (_categoria == TipoContenido.lugar) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _latitudController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitud (opcional)',
                        hintText: 'Entre -90 y 90',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.latitud,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _longitudController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitud (opcional)',
                        hintText: 'Entre -180 y 180',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.longitud,
                    ),
                  ],
                  if (_categoria == TipoContenido.plato) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tipoPlatoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de plato',
                        hintText: 'Ejemplo: sopa, guiso o postre',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.tipoPlato,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio referencial (opcional)',
                        prefixText: 'S/ ',
                        hintText: 'Ingrese un valor igual o mayor que 0',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validadores.precio,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        _selectedImagePath == null
                            ? 'Adjuntar fotografía (recomendado)'
                            : 'Cambiar fotografía',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImagePath != null)
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GuideImage(imagePath: _selectedImagePath!),
                      ),
                    ),
                  const Text(
                    'La fotografía se copia al almacenamiento privado de la app; '
                    'en web queda en la base local del navegador.',
                  ),
                  if (_errorGeneral != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorGeneral!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _guardando ? 'Guardando...' : 'Guardar contenido',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictField() => FormField<String>(
    initialValue: _distrito,
    validator: Validadores.distrito,
    builder: (field) => DropdownButtonFormField<String>(
      initialValue: field.value,
      decoration: InputDecoration(
        labelText: 'Distrito',
        border: const OutlineInputBorder(),
        errorText: field.errorText,
      ),
      items: DatosFormulario.kDistritos
          .map(
            (district) =>
                DropdownMenuItem(value: district, child: Text(district)),
          )
          .toList(),
      onChanged: (value) {
        _distrito = value;
        field.didChange(value);
      },
    ),
  );

  Widget _buildDateField() => FormField<DateTime>(
    initialValue: _fecha,
    validator: Validadores.fecha,
    builder: (field) => InputDecorator(
      decoration: InputDecoration(
        labelText: 'Fecha de la festividad',
        errorText: field.errorText,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _fecha == null
                  ? 'Seleccione una fecha válida'
                  : '${_fecha!.day.toString().padLeft(2, '0')}/'
                        '${_fecha!.month.toString().padLeft(2, '0')}/'
                        '${_fecha!.year}',
            ),
          ),
          IconButton(
            tooltip: 'Elegir fecha',
            onPressed: () => _seleccionarFecha(field),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    ),
  );
}
