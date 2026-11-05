import 'package:flutter_test/flutter_test.dart';
import 'package:tea_g3_studio/models/edit_decision_list.dart';
import 'package:tea_g3_studio/models/video_clip.dart';

void main() {
  group('EditDecisionList', () {
    test('creates a sequential timeline from clip ranges', () {
      final plan = EditDecisionList.fromClips(
        projectId: 'project-1',
        clips: const [
          VideoClip(id: 'a', name: 'a.mp4', path: '/a', startMs: 100, endMs: 600),
          VideoClip(id: 'b', name: 'b.mp4', path: '/b', startMs: 50, endMs: 250),
        ],
      );

      expect(plan.validate(), isEmpty);
      expect(plan.timeline[0].timelineStartMs, 0);
      expect(plan.timeline[1].timelineStartMs, 500);
      expect(plan.toJson()['status'], 'draft');
    });

    test('uses source duration when end point is not yet populated', () {
      final plan = EditDecisionList.fromClips(
        projectId: 'project-1',
        clips: const [
          VideoClip(
            id: 'a',
            name: 'a.mp4',
            path: '/a',
            startMs: 100,
            endMs: 0,
            sourceDurationMs: 1000,
          ),
        ],
      );
      expect(plan.timeline.single.sourceOutMs, 1000);
    });

    test('rejects an invalid range', () {
      expect(
        () => EditDecisionList.fromClips(
          projectId: 'project-1',
          clips: const [
            VideoClip(id: 'a', name: 'a.mp4', path: '/a', startMs: 500, endMs: 100),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('reports missing project identifiers', () {
      const plan = EditDecisionList(projectId: ' ', timeline: []);
      expect(plan.validate(), contains('Project ID is required.'));
    });
  });
}
