import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum _Mode { builder, listen }

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  _Mode _mode = _Mode.builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: SafeArea(
        child: Column(
          children: [
            SegmentedButton<_Mode>(
              segments: const [
                ButtonSegment(
                  value: _Mode.builder,
                  label: Text('StreamBuilder'),
                ),
                ButtonSegment(value: _Mode.listen, label: Text('Listen')),
              ],
              selected: {_mode},
              onSelectionChanged: (value) {
                setState(() => _mode = value.first);
              },
            ),
            Expanded(
              child: Center(
                child: _mode == _Mode.builder
                    ? const _BuilderCountdown()
                    : const _ListenCountdown(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuilderCountdown extends StatefulWidget {
  const _BuilderCountdown();

  @override
  State<_BuilderCountdown> createState() => _BuilderCountdownState();
}

class _BuilderCountdownState extends State<_BuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data ?? 10}',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late final StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) {
      setState(() => _left = value);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_left', style: Theme.of(context).textTheme.displayLarge);
  }
}
