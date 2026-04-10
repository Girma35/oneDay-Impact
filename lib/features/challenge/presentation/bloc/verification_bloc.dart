import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';

// Events
abstract class VerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyChallengeStarted extends VerificationEvent {
  final String challengeDescription;
  final File image;

  VerifyChallengeStarted({required this.challengeDescription, required this.image});

  @override
  List<Object?> get props => [challengeDescription, image];
}

// States
abstract class VerificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {}
class VerificationLoading extends VerificationState {}
class VerificationSuccess extends VerificationState {
  final bool isVerified;
  VerificationSuccess(this.isVerified);
  @override
  List<Object?> get props => [isVerified];
}
class VerificationFailure extends VerificationState {
  final String message;
  VerificationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository repository;

  VerificationBloc({required this.repository}) : super(VerificationInitial()) {
    on<VerifyChallengeStarted>((event, emit) async {
      emit(VerificationLoading());
      try {
        final isVerified = await repository.verifyChallengeCompletion(
          challengeDescription: event.challengeDescription,
          image: event.image,
        );
        emit(VerificationSuccess(isVerified));
      } catch (e) {
        emit(VerificationFailure(e.toString()));
      }
    });
  }
}
