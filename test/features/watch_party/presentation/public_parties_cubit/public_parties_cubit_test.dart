import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_public_watch_parties.dart';
import 'package:sync_together/features/watch_party/presentation/public_parties_cubit/public_parties_cubit.dart';

class MockGetPublicWatchParties extends Mock implements GetPublicWatchParties {}

void main() {
  late PublicPartiesCubit cubit;
  late MockGetPublicWatchParties mockGetPublicWatchParties;

  final testFailure = GetWatchPartyFailure(
    message: 'Failed to fetch',
    statusCode: 500,
  );
  final testParties = [
    WatchParty.empty(),
    WatchParty.empty(),
  ];

  setUp(() {
    mockGetPublicWatchParties = MockGetPublicWatchParties();
    cubit = PublicPartiesCubit(mockGetPublicWatchParties);
  });

  tearDown(() => cubit.close());

  test('initial state should be WatchPartyListInitial', () {
    expect(cubit.state, equals(WatchPartyListInitial()));
  });

  blocTest<PublicPartiesCubit, WatchPartyListState>(
    'emits [Loading, Loaded] when fetchPublicParties is successful',
    build: () {
      when(() => mockGetPublicWatchParties()).thenAnswer(
        (_) async => Right(testParties),
      );
      return cubit;
    },
    act: (cubit) => cubit.fetchPublicParties(),
    expect: () => [
      WatchPartyListLoading(),
      WatchPartyListLoaded(testParties),
    ],
    verify: (_) {
      verify(() => mockGetPublicWatchParties()).called(1);
    },
  );

  blocTest<PublicPartiesCubit, WatchPartyListState>(
    'emits [Loading, Error] when fetchPublicParties fails',
    build: () {
      when(() => mockGetPublicWatchParties()).thenAnswer(
        (_) async => Left(testFailure),
      );
      return cubit;
    },
    act: (cubit) => cubit.fetchPublicParties(),
    expect: () => [
      WatchPartyListLoading(),
      WatchPartyListError(testFailure.message),
    ],
    verify: (_) {
      verify(() => mockGetPublicWatchParties()).called(1);
    },
  );
}
