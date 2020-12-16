import 'dart:math';

enum District {
  SHEVCHENKOVSKIY,
  KIEVSKIY,
  SLOBODSKOY,
  HOLODNOGORSKIY,
  MOSKOVSKIY,
  NOVOBAVARSKIY,
  INDUSTRIALNIY,
  NEMISHLYIANSKIY,
  OSNOVIYANSKIY
}

extension DistrictPopulationPercentage on District {
  double get populationPercentage {
    switch (this) {
      case District.SHEVCHENKOVSKIY:
        return 0.158;

      case District.KIEVSKIY:
        return 0.130;

      case District.SLOBODSKOY:
        return 0.101;

      case District.HOLODNOGORSKIY:
        return 0.058;

      case District.MOSKOVSKIY:
        return 0.203;

      case District.NOVOBAVARSKIY:
        return 0.077;

      case District.INDUSTRIALNIY:
        return 0.106;

      case District.NEMISHLYIANSKIY:
        return 0.101;

      case District.OSNOVIYANSKIY:
        return 0.066;

      default:
        return 0;
    }
  }
}

extension DistrictName on District {
  String get name {
    switch (this) {
      case District.SHEVCHENKOVSKIY:
        return "Шевченковский район";
      case District.KIEVSKIY:
        return "Киевский район";
      case District.SLOBODSKOY:
        return "Слободской район";
      case District.HOLODNOGORSKIY:
        return "Холодногорский район";
      case District.MOSKOVSKIY:
        return "Московский район";
      case District.NOVOBAVARSKIY:
        return "Новобаварский район";
      case District.INDUSTRIALNIY:
        return "Индустриальный район";
      case District.NEMISHLYIANSKIY:
        return "Немышлянский район";
      case District.OSNOVIYANSKIY:
        return "Основянский район";
      default:
        return "";
    }
  }
}

extension DistrictDistributor on District {
  static District distribute() {
    double randomNumber = Random().nextDouble();
    double startRange = 0;
    for (var district in District.values) {
      double endRange = startRange + district.populationPercentage;
      if (startRange < randomNumber && randomNumber < endRange) {
        return district;
      } else {
        startRange += district.populationPercentage;
      }
    }
    return null;
  }
}
