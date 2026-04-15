import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';
import 'package:one_day/features/challenge/domain/repositories/completed_challenge_repository.dart';

// Events
abstract class VerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyChallengeStarted extends VerificationEvent {
  final String challengeId;
  final String challengeDescription;
  final List<String> verificationKeywords;
  final XFile image;

  VerifyChallengeStarted({
    required this.challengeId,
    required this.challengeDescription,
    required this.verificationKeywords,
    required this.image,
  });

  @override
  List<Object?> get props => [challengeId, challengeDescription, verificationKeywords, image.path];
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
  final CompletedChallengeRepository _completedRepo;

  VerificationBloc({
    required this.repository,
    required CompletedChallengeRepository completedRepo,
  })  : _completedRepo = completedRepo,
        super(VerificationInitial()) {
    on<VerifyChallengeStarted>((event, emit) async {
      emit(VerificationLoading());
      try {
        final isVerified = await repository.verifyChallengeCompletion(
          challengeDescription: event.challengeDescription,
          verificationKeywords: event.verificationKeywords,
          image: event.image,
        );
        
        if (isVerified) {
          // Upload proof image & record completion in Supabase
          String? proofUrl;
          try {
            final supabase = Supabase.instance.client;
            final fileExt = event.image.name.contains('.')
                ? event.image.name.split('.').last
                : 'jpg';
            final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
            final imageBytes = await event.image.readAsBytes();
            
            await supabase.storage.from('challenge_proofs').uploadBinary(
              fileName,
              imageBytes,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: true,
                contentType: event.image.mimeType ?? 'image/jpeg',
              ),
            );
            proofUrl = supabase.storage.from('challenge_proofs').getPublicUrl(fileName);
          } catch (e) {
            // Proof upload failed — continue without URL
            debugPrint('Proof upload failed: $e');
          }

          // Record the completion via the secure RPC function
          try {
            await _completedRepo.completeChallenge(
              challengeId: event.challengeId,
              proofImageUrl: proofUrl,
            );
          } catch (e) {
            // Duplicate or other DB error — don't fail the UI
            debugPrint('Complete challenge recording failed: $e');
          }
        }
        
        emit(VerificationSuccess(isVerified));
      } catch (e) {
        emit(VerificationFailure(e.toString()));
      }
    });
  }
}
