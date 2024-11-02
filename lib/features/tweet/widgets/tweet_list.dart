import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(getTweetsProvider);
      },
      child: ref.watch(getTweetsProvider).when(
            data: (tweets) {
              return ref.watch(getLatestTweetProvider).when(
                    data: (data) {
                      if (data.isNotEmpty) {
                        if (data["tweetAction"] == "CREATE") {
                          tweets.insert(0, Tweet.fromMap(data["tweet"]));
                        } else if (data["tweetAction"] == "UPDATE") {
                          Tweet updatedTweet = Tweet.fromMap(data["tweet"]);

                          var tweet = tweets
                              .where((element) => element.id == updatedTweet.id)
                              .first;

                          final tweetIndex = tweets.indexOf(tweet);
                          tweets.removeWhere(
                              (element) => element.id == updatedTweet.id);

                          tweets.insert(tweetIndex, updatedTweet);
                        }
                      }

                      return ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
                      );
                    },
                    error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                    loading: () {
                      return ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
                      );
                    },
                  );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
