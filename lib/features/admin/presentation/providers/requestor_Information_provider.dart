import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/data/mock/requestor_Information_mock_data.dart';
import 'package:jtrips_app/features/admin/data/models/requestor_Information_model.dart';

final requestorInformationProvider = Provider<List<RequestorInformationModel>>((ref) => requestorInformationMockData);