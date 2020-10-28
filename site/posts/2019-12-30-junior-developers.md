---
title: "Hire and Train Haskell Junior Developers"
author: Vladimir Ciobanu
date: Dec 30, 2019
tags: [personal, fp, haskell]
description: "A plea to senior developers and team leads"
---

## TL;DR

I think the reason we don't have more people doing Haskell is we're not actually
hiring junior developers, and when we do, we don't set them up for success by
properly training them.

## Introduction

This post was sparked by a few other posts in the Haskell world. They are, to my
knowledge, in chronological order:
- Michal Snoyman's [Boring Haskell Manifesto](https://www.snoyman.com/blog/2019/11/boring-haskell-manifesto)
- Matt Parsons' [Write Junior Code](https://www.parsonsmatt.org/2019/12/26/write_junior_code.html)
- Marco Sampellegrini's [My thoughts on Haskell in 2020](https://alpacaaa.net/thoughts-on-haskell-2020/)

Snoyman's manifesto is a call to define a safe subset of the Haskell language
and common libraries, provide documentation, tutorials, cookbooks, and
continuously evolve, update, and help engineers use and get "boring Haskell"
adopted.

Parsons notes that Haskell has a hiring problem: there are few jobs, and most
of those are for senior developers. The reason for this is that we
over-indulge in fancy Haskell, making our code needlessly complicated. If we
wrote simple, junior-level Haskell, we would be able to hire junior developers
and have them be productive.

Sampellegrini's post points out a few key problems:
- there's a lot of extensions we need to keep track of, which makes things hard
- if an idea looks good on paper, it doesn't mean it's going to be easy to
  maintain in the long run
- inclusivity might be a problem: "I don't want a PhD to be a requirement to
  work with Haskell"
- they argue there's marginal benefit to fancy types/Haskell

While I understand where all of these feelings are coming from, and I agree to
some of the ideas, I think they have their marks on the wrong problem.

## The Real Problem

I think the real problem is that we are not putting up jobs for junior devs. We're
not even giving them a chance. And when we are, we usually don't give them
enough support (through training and making sure they know who to ask, and that
it's okay to do so) to succeed.

I'm really not sure why we're not hiring more junior developers. It might be
because seniors like to think that the code they are writing is so complicated
that a junior would take too long to be able to understand, so they advise
management that a junior cannot possibly be productive. Maybe it's because they
don't want to be bothered with training junior devs, and they would rather just work
on code instead? Or maybe it's because management doesn't like seniors' time
being "wasted" on teaching junior devs?

Whatever the reason, I don't really think writing simpler code will help much.
If the on-boarding process is lacking, if the company culture is not welcoming to
junior devs, most of them will be set for failure from the get-go, regardless of how
fancy or simple the code is.

## Junior Developers

What is a junior developer? For the purposes of this article, I will define a
Haskell junior developer as somebody who's able to confidently use simple monads
like `Maybe`, `Either e`, `IO`, and the list monad. Ideally, they would also
have a crude understanding of monad transformers (but not necessarily `mtl` as
well). They are able to compose functions, reason about ADTs, and, perhaps most
importantly, are motivated to learn more about Haskell and FP.

I currently work on two projects, both in Haskell. One of these projects has two
junior Haskell developers, and the other has one. I will briefly go over the
details of these projects as well as my mentoring experience in order to
establish a baseline.

I have not been working with Haskell for very long. I actually come from OOP-land
(you can [read my story here](https://cvlad.info/haskell/)), and I have a lot of
experience as a team lead. I have hired, trained, and mentored a decent number of
junior devs, most of them in my OOP days, but also three of them recently, at
the place I currently work. For the past year and a half, I have been the main
developer in charge of training and making sure the junior devs are productive.

Our codebases (you can [see one of them
here](https://github.com/kframework/kore)) are pretty complicated: besides the
fact that they use notoriously complex Haskell libraries such as `lens`,
`servant`, and `recursion-schemes`, the domain problem is pretty complicated as
well: we're essentially building an automated prover for a rewrite-based
executable semantic framework (the other project is a pretty standard servant
app, so not too much to go over there, although it does use `lens`,
`generic-lens`, `persistent`/`esqueleto` and obviously `servant`).

This prelude was needed because I can't really speak about junior developers in
general, but I can tell you about my experience with on-boarding junior Haskell
developers on our projects. However, before that, I would like to add that the
junior devs we hired were all either senior year at the local university, or fresh
graduates. They were picked because they are all excited about FP, despite the
fact that none of them had any previous professional experience related to FP or
Haskell.

I am proud to say that all three junior devs are doing great. I obviously can't take
any significant part of the credit (they are all very smart and hard working),
but I think that there are a few things that contributed to their success:
- **Kindness** we've all gone through this. We're all trying our best. Be kind and
  supportive. Praise them when they do a good job. Encourage them to come up
  with ideas and to bring their ideas forward.
- **Confidence** make sure they know it's okay to not know things; there's a ton of
  things I don't know, and I make sure to be loud about it. I also make sure to
  show them how I find the answers to things I don't know. Of course, on top of
  literally telling them it's okay to ask questions and not know stuff, even if
  it feels like it's something they should know (there's no such thing, really:
  we all have our blind spots).
- **Support** be there for them. We have daily meetings and we make sure we know
  what everybody's up to. We make sure to ask everybody if they're stuck or not,
  if they need help or more work.
- **Training** at least until they get comfortable, make sure you go over the things
  that are "fancy" in the codebase. At the very least, make sure you go over a
  few examples and show them how it works. Make sure they understand. A few
  exercises where you work together can be particularly useful as well.
- **Clarity** it is vitally important that tasks are as crystal-clear as they can
  be. Make extra sure the tasks that junior devs work on won't take them too far off
  the beaten path. Try to add comments/more notes to these tasks: where to
  start, a very rough sketch of the solution, how to test: anything can help.

Only one of the three junior developers we hired was slightly familiar with
monad transformers at the time they were hired. The other two were familiar with
monads. We were able to get all three to contribute PRs in less than a week after
they started. Within 3 to 6 months, I noticed they started being able to
complete tasks with little supervision. One of them has been with us for little
over an year, and they are now able to take on complicated tasks (major
refactoring, learning new concepts, etc.) pretty much on their own.

## You can't possibly teach a junior X in Y days

Since the subject is hot, I just saw a [tweet from Joe Kachmar](https://twitter.com/jkachmar/status/1210977393197883393)
which expresses the very idea I want to combat: these things aren't THAT hard to
teach. Of course a junior won't be able to invent a new type of lenses, add a
new layer to our application's monad stack, or re-invent `generic-lens`, but
nobody's expecting them to.

After a week of training, I am sure a junior developer can add a new REST API
endpoint that is similar to one that's already in our application. They can use
getter lenses similar to the ones we already have, but targeting different
fields: they can re-use the existing infrastructure to write "boring" code using
whatever level of fancy Haskell is already there as a guide.

And sure, sometimes they'll try something new and they'll get stuck on a 20-page
GHC type error. That's when they ask for help, because they know it's okay not
knowing things, and there's always someone available that's happy to help (and they
won't help by fixing the error for them, but by guiding them into understanding
and fixing the problem themselves).

## Why not both?

It's hard to focus on multiple solutions to the same problem. I am also worried
that the "Boring Haskell Manifesto" can even be harmful in the long run.

Writing programs is really, really hard. Nothing focuses this feeling better than
writing pure FP, because it forces you to be clear, precise and thorough about
everything: you can't ignore `Nothing`s, you can't discard `Left`s implicitly,
you don't get to shove things into a mutable global state.

Writing programs is really, really hard for everyone. It's not only hard for
junior developers. It's also hard for senior developers. We haven't figured this
out, we're not even close. We still have a terrible story for errors: their
composability is far from ideal. We still have a lot of competing libraries for
effects, and more seem to be coming. There are a lot of libraries to be explored
and discovered.

I do think that each team should be careful when adding language extensions and
choosing libraries for each project they work on. And I do think the "fancyness"
needs to be taken into account. As Parsons put it on slack
> fanciness of your code should be gated on the size of your mentoring/training
> budget if you value hiring juniors

I totally agree, although I would also add that another important aspect worth
considering is the benefit of said fancyness.

There are many reasons one might want to stray off the beaten path. Fancy
type-level code might save you a ton of code duplication, or it might add
features that would otherwise make the code brittle or hard to maintain. For
some projects, this may be worth it.

I don't think a blessed set of libraries or extensions will help with this.
Which streaming library gets to be picked? Will it be `conduit` over `pipes`?
What about `streaming`? 

As I said, I think it's the wrong thing to focus on.

## Conclusion

We need to stop over-appreciating how hard it is to use "fancy" libraries like
`servant`, `lens` or `recursion-schemes`. Give junior developers a fighting
chance and they will surprise you.

I don't think there's anything that makes our company's junior developer success
story non-reproducible anywhere else. Our local university doesn't focus on FP
or Haskell (they do have one course where they teach Haskell, but that's pretty
much it). We were actually forced to take this route because there's no other
companies that do Haskell locally (as far as I know), so we can't just find
Haskell developers around.

I think this is reproducible anywhere, on pretty much any codebase. We just need
to open up junior positions, and give them the support they need to succeed.
Have you had some different experience? Is it hard to find junior developers
that are somewhat familiar with monads?

Go out there, convince your team that they're not actually living in an ivory
tower. It's not that hard, and we're not special for understanding how to use
these language extensions and libraries. We can teach junior developers how to
use them. 
