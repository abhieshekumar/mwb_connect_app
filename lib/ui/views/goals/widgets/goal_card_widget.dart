import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';

class GoalCard extends StatefulWidget {
  const GoalCard({Key key, @required this.goal}): 
    super(key: key);

  final Goal goal;

  @override
  State<StatefulWidget> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  GoalsViewModel _goalProvider;  

  Widget _showGoalCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
      child: Card(
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.goal.text,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18
              ),
            ),
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return GestureDetector(
      onTap: (){
        _goalProvider.setSelectedGoal(widget.goal);
        _goalProvider.setShouldShowTutorialChevrons(false);
        _goalProvider.setIsTutorialPreviewsAnimationCompleted(false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => GoalStepsView()));
      },
      child: _showGoalCard()
    );
  }
}