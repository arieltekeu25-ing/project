/// Données des villes et quartiers du Cameroun
class CameroonCities {
  static const Map<String, List<String>> citiesAndDistricts = {
    'Douala': [
      'Akwa',
      'Bonapriso',
      'Bonanjo',
      'Bepanda',
      'Makepe',
      'Logbaba',
      'Ndogpassi',
      'New Bell',
      'Kotto',
      'Bastos',
      'Bonamoussadi',
      'Deido',
    ],
    'Yaoundé': [
      'Bastos',
      'Mvan',
      'Ekoumdoum',
      'Messamendongo',
      'Ngoa-Ekelle',
      'Nkolbisson',
      'Olembe',
      'Omnisports',
      'Tsinga',
      'Melen',
      'Ngousso',
      'Biyem-Assi',
      'Elig-Essono',
      'Nsam',
      'Kondengui',
    ],
    'Bafoussam': [
      'Djombog',
      'Baleng',
      'Koptchou',
    ],
    'Garoua': [
      'Béka',
      'Garoua-Boulai',
    ],
    'Bamenda': [
      'Nkwen',
      'Bamenda I',
      'Bamenda II',
      'Bamenda III',
      'Mankon',
    ],
    'Buea': [
      'Molyko',
      'Buea Town',
      'Limbe',
      'Tiko',
      'Mutengene',
    ],
    'Nkongsamba': [
      'Nkongsamba',
      'Mbanga',
      'Edea',
    ],
    'Kribi': [
      'Kribi',
      'Lolabe',
      'Campo',
    ],
    'Edéa': [
      'Edéa',
      'Mbanga',
      'Nkongsamba',
    ],
    'Maroua': [
      'Maroua',
      'Mokolo',
      'Kousseri',
    ],
    'Ngaoundéré': [
      'Ngaoundéré',
      'Tibati',
      'Meiganga',
    ],
    'Bertoua': [
      'Bertoua',
      'Batouri',
      'Yokadouma',
    ],
    'Doumé': [
      'Doumé',
      'Abong-Mbang',
    ],
    'Sangmélima': [
      'Sangmélima',
      'Mintom',
      'Ebolowa',
    ],
    'Ebolowa': [
      'Ebolowa',
      'Sangmélima',
      'Kribi',
    ],
    'Kumba': [
      'Kumba',
      'Mbanga',
      'Loum',
    ],
    'Limbe': [
      'Limbe',
      'Buea',
      'Tiko',
    ],
    'Dschang': [
      'Dschang',
      'Bafoussam',
      'Foumban',
    ],
    'Foumban': [
      'Foumban',
      'Bafoussam',
      'Dschang',
    ],
    'Kousseri': [
      'Kousseri',
      'Maroua',
      'Mokolo',
    ],
    'Mokolo': [
      'Mokolo',
      'Maroua',
      'Kousseri',
    ],
    'Batouri': [
      'Batouri',
      'Bertoua',
      'Yokadouma',
    ],
    'Yokadouma': [
      'Yokadouma',
      'Batouri',
      'Bertoua',
    ],
    'Mintom': [
      'Mintom',
      'Sangmélima',
      'Ebolowa',
    ],
    'Mbanga': [
      'Mbanga',
      'Kumba',
      'Loum',
    ],
    'Loum': [
      'Loum',
      'Kumba',
      'Mbanga',
    ],
    'Tiko': [
      'Tiko',
      'Limbe',
      'Buea',
    ],
    'Kumbo': [
      'Kumbo',
      'Bamenda',
      'Nkwen',
    ],
  };

  static const List<String> propertyTypes = [
    'Appartement',
    'Studio',
    'Villa',
    'Maison',
    'Bureau',
    'Boutique',
    'Entrepôt',
    'Terrain',
    'Chambre',
    'Duplex',
    'Triplex',
  ];

  static List<String> get allCities => citiesAndDistricts.keys.toList();

  static List<String> getDistricts(String city) {
    return citiesAndDistricts[city] ?? [];
  }

  static List<String> get allDistricts {
    return citiesAndDistricts.values.expand((list) => list).toList();
  }
}
