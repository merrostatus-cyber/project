import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/calc_service.dart';

final calcServiceProvider = Provider<CalcService>((ref) => CalcService());
