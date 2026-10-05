import 'package:flutter/material.dart';

import '../models/guide_models.dart';

const guideCategories = [
  GuideCategory(
    'Lugares',
    Icons.account_balance_outlined,
    'assets/images/categorias/lugares.jpg',
  ),
  GuideCategory(
    'Festividades',
    Icons.celebration_outlined,
    'assets/images/categorias/festividades.jpg',
  ),
  GuideCategory(
    'Gastronomía',
    Icons.restaurant_outlined,
    'assets/images/categorias/gastronomia.jpg',
  ),
  GuideCategory(
    'Tradiciones',
    Icons.auto_awesome_outlined,
    'assets/images/categorias/tradiciones.jpg',
  ),
];

const guideSections = [
  GuideSection(
    title: 'Lugares',
    subtitle: 'Rincones que cuentan siglos',
    places: [
      GuidePlace(
        name: 'Machu Picchu',
        category: 'Maravilla',
        imagePath: 'assets/images/lugares/machu_picchu.jpg',
        tags: ['UNESCO', 'Inca'],
      ),
      GuidePlace(
        name: 'Sacsayhuamán',
        category: 'Arqueología',
        imagePath: 'assets/images/lugares/sacsayhuaman.jpg',
        tags: ['Historia', 'Piedra'],
      ),
      GuidePlace(
        name: 'Plaza de Armas',
        category: 'Centro histórico',
        imagePath: 'assets/images/lugares/plaza_de_armas.jpg',
        tags: ['Ciudad', 'Colonial'],
      ),
      GuidePlace(
        name: 'Valle Sagrado',
        category: 'Naturaleza',
        imagePath: 'assets/images/lugares/valle_sagrado.jpg',
        tags: ['Paisaje', 'Andes'],
      ),
    ],
  ),
  GuideSection(
    title: 'Festividades',
    subtitle: 'Rituales, música y comunidad',
    places: [
      GuidePlace(
        name: 'Inti Raymi',
        category: 'Junio',
        imagePath: 'assets/images/festividades/inti_raymi.jpg',
        tags: ['Sol', 'Tradición'],
      ),
      GuidePlace(
        name: 'Corpus Christi',
        category: 'Procesión',
        imagePath: 'assets/images/festividades/corpus_christi.jpg',
        tags: ['Fe', 'Cultura'],
      ),
      GuidePlace(
        name: 'Virgen del Carmen',
        category: 'Festividad',
        imagePath: 'assets/images/festividades/virgen_del_carmen.jpg',
        tags: ['Tradición', 'Cusco'],
      ),
      GuidePlace(
        name: 'Feria artesanal de Pisac',
        category: 'Artesanía',
        imagePath: 'assets/images/festividades/feria_de_pisac.jpg',
        tags: ['Pisac', 'Cultura'],
      ),
    ],
  ),
  GuideSection(
    title: 'Gastronomía',
    subtitle: 'Sabores nacidos en los Andes',
    places: [
      GuidePlace(
        name: 'Chiri uchu',
        category: 'Plato bandera',
        imagePath: 'assets/images/gastronomia/chiri_uchu.jpg',
        tags: ['Festivo', 'Andino'],
      ),
      GuidePlace(
        name: 'Costillar y frutillada',
        category: 'Tradicional',
        imagePath: 'assets/images/gastronomia/costillar_frutillada.jpg',
        tags: ['Cusco', 'Frutillada'],
      ),
      GuidePlace(
        name: 'Anticuchos cusqueños',
        category: 'A la parrilla',
        imagePath: 'assets/images/gastronomia/anticuchos_cusquenos.jpg',
        tags: ['Anticucho', 'Local'],
      ),
      GuidePlace(
        name: 'Quesos del mercado',
        category: 'Producto local',
        imagePath: 'assets/images/gastronomia/quesos_cusquenos.jpg',
        tags: ['Mercado', 'Cusco'],
      ),
    ],
  ),
];
