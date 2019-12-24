<name> text
> <name> text in a thread

## Tuesday, December 17th

<ProofTechnique> If I wanted to work through the HoTT book both by hand (because I'm comfortable with creating human proofs) and with a theorem prover (because I've used Agda a little but I'm not wildly comfortable with theorem provers), what would be a reasonable proof assistant to use? I've heard good things about Lean, but Coq and Agda are obviously quite popular. Mainly I'm curious what'll have enough "built-in" that I won't have to spend a year writing a Prelude just to talk about problems in the book, but not so much that every theorem will just be written for me because it's already in a library.
> <totbwf> Cubical Agda has a full HoTT module
> <ProofTechnique> That's certainly promising, then. I guess that puts Agda at the top of my list for a companion to my manual proofs
> <totbwf> https://github.com/agda/cubical/blob/master/Cubical/Foundations/HoTT-UF.agda is the module to use for book hott btw, should hide all of the hairy cubical stuff
> <ProofTechnique> Well, ain't you just full of helpful advice? :slightly_smiling_face: Guess I'll have to make sure to update my Agda checkout in Nix
> <ProofTechnique> Is 2.6.0.1 new enough (if you know)?
> <ProofTechnique> Oh, I see the README
> <ProofTechnique> I'll get a dev checkout
> <totbwf> Let's just say I've spent a while bashing my head against it lol
> <ProofTechnique> Well, if I could prevail on you to hold my hand here and there when I hit my head, I'd certainly appreciate it
> <totbwf> Of course! No sense learning something if you aren't willing to share it
> <ProofTechnique> You've already given me lots of good stuff to go on, so hopefully I'll be able to make a little progress on my day off tomorrow
> <totbwf> Glad I could help :slightly_smiling_face:

<ProofTechnique> 'm leaning (haw) toward Lean (unless there's a compelling case otherwise). The prelude looks sane enough that I won't have to reinvent mathematics to do mathematics, but I can also use namespaces to happily reinvent the bits that I want to without interference from the libraries. :relaxed:
<cvlad> I know @monoidmusician is big into Lean. I never got around to playing with it myself.
<monoidmusician> Lean might not have the best support for HoTT ... but I like it otherwise
<monoidmusician> in particular, my understanding is that most of the standard libraries don't work with HoTT
<monoidmusician> Lean has an interesting culture of both CS and math people working on it, but both groups are generally wary of HoTT so it isn't a priority for most of the community
<monoidmusician> I think Lean 2 supported HoTT fairly well, Lean 3 can maybe do it with some hacks/restrictions, and Lean 4 is on the horizon and probably won't prioritize supporting it
<ProofTechnique> Hmm. Maybe I'll play around with Coq and Lean, then. At least until I start hitting things that I can't express in Lean, it seems like a nice enough tool to use
<ProofTechnique> I appreciate the informed opinion :blush:
<monoidmusician> https://github.com/gebner/hott3
<monoidmusician> Lean has a zulip chat btw
<ProofTechnique> :nice: I'll definitely have to check it out.
<ProofTechnique> @monoidmusician This discussion on sheaves on the Zulip is very funny and perfectly encapsulates what you said about the culture of math and CS people
<ProofTechnique> Thanks again for the pointer
<monoidmusician> I think it would be cool to create a proof assistant where the language is more like category theory, but the underlying formalism is HoTT, but preferably with configurable axioms for computability or maths, etc.
<monoidmusician> I love type theory, but it's slightly too low-level to be convenient for notation
<monoidmusician> and I think there's something more than just syntactic sugar that needs to change
<mdl> @monoidmusician it's not a proof assistant, but if you've never seen it, you may find FriCAS interesting
<mdl> (and the related compiler/language that was written for it as an add-on, aldor)
<mdl> it's like a ML that independently invented typeclasses and a mild notion of dependent types, but all the classes are built around algebraic structures instead of category theory or an obvious type theory
<mdl> (or you may have heard of its predecessor as well, axiom)
<monoidmusician> interesting, I'll put it on the list to look at, thanks :slightly_smiling_face:
<ArielG> I think Agda is currently probably the best language to learn type theory with, including HoTT (especially since it has an experimental support for Cubical Type Theory).
<ArielG> In Coq you usually don't really write proof terms, but instead work with tactics which generate proofs from a metalanguage, so you don't "feel" the type theory as much as you do in Agda (where you are forced to write proof terms directly).
<ArielG> In any case both Agda and Coq doesn't have a support for higher inductive types (and I'm not really sure how good Agda support for path types is), so for a "full-featured" HoTT you'll probably want to try a language based on Cubical Type Theory such as RedTT, but the downside is that it might be yet too experimental to write more complicated proofs.
<monoidmusician> :point_up: this is good advice
<monoidmusician> I'm trying to read some introductions to cubical type theory right now, it's really interesting
<mdl> coq used to have a "mathematical proof language" inspired by isar/isabelle called c-zar; it was much nicer to read imo...but since it wasn't the default and it lacked feature parity, it had few users, and eventually bitrotted and was removed since nobody stepped up to maintain it
<ArielG> You can also write proof terms directly in Coq, but the overemphasis on tactics in most tutorials and documents makes you feel dirty when you do so.
<ProofTechnique> @ArielG I appreciate the additional options. I'll have a look at RedTT. It hadn't come up in my searches before :slightly_smiling_face:
<ProofTechnique> @ArielG Ooh!
<ProofTechnique> > update: there is now {-# OPTIONS --cubical #-} and HITs
<ProofTechnique> according to https://ncatlab.org/homotopytypetheory/show/Agda
<ProofTechnique> Though it doesn't actually provide any details, so who knows?<Paste>
<ProofTechnique> https://agda.readthedocs.io/en/v2.6.0.1/language/cubical.html
docs to the rescue
<ArielG> @ProofTechnique Yeah unfortunately Cuibcal Agda is not very well documented, and RedTT isn't documented at all (so your only recourse is to learn from the examples), sorry
<ProofTechnique> Meh, I work in industry; documentation is never expected :smile:
<ArielG> oh it's good to hear they've added HITs for Cubical Agda<Paste>
<ProofTechnique> This is comforting, because I'm definitely miles more comfortable with Agda than the other options
<ArielG> Yeah that makes sense
<ArielG> BTW I think Cubical Agda is based on the original Cubical Type Theory paper, while RedTT is much more cutting edge (it has something called "extension types" which is like path types on steroids with a better syntax)
<ProofTechnique> I'll definitely check out the examples. Worst case, maybe I can write some actual docs :grin:
<ArielG> That would be awesome
<ProofTechnique> The Cubical Agda paper (https://www.researchgate.net/publication/334757469_Cubical_agda_a_dependently_typed_programming_language_with_univalence_and_higher_inductive_types) is remarkably readable
<totbwf> I've written a decent amount of cubical agda, been working on a blog post for way too long
<totbwf> It's definitely very usable, but learning how to decipher the constraints can be quite overwhelming at 1st
<totbwf> Same goes for some of the connection stuff
<ProofTechnique> @totbwf What's your blog? I'd love to read more (and watch out for the cubical Agda post)
<totbwf> It's very barren right now
<totbwf> http://totbwf.github.io/
<ProofTechnique> Still one more post than my blog right now :smile:
<totbwf> https://github.com/TOTBWF/TOTBWF.github.io/tree/wip/posts has the WIP post
<totbwf> I got distracted by working on embeding 3d visualizations into the post lol
<ProofTechnique> That would explain that mess of JS at the head of the Org file :smile:
<totbwf> shhhhh
<totbwf> Ignore the tikz as well

### Wednesday, December 18th
<monoidmusician> okay, it's been 20 hours, I'm sold on cubical type theory now :smile:
<ProofTechnique> @monoidmusician Out of curiosity, which intros did you read? I'm just getting things set up in Agda right now, so I wouldn't mind something to read while I wait for library checks to finish :smile:
<monoidmusician> I think it's been a good idea to just hammer the thing with many different approaches at once, here's some I've read in part:
- https://homotopytypetheory.org/2017/09/16/a-hands-on-introduction-to-cubicaltt/
- https://ncatlab.org/homotopytypetheory/files/MortbergBonn.pdf <- this was actually really helpful
- https://homotopytypetheory.org/2018/12/06/cubical-agda/
- https://agda.readthedocs.io/en/v2.6.0.1/language/cubical.html#the-interval-and-path-types (linked from Reed's WIP)
- and the Cubical Agda paper you linked to above
<totbwf> One of us, one of us 
<boarders> How much do you need to have a good grasp on cubical sets to get along with cubical agda (I know some of the basics with a de morgan interval object)?
<totbwf> Basically none tbh
<boarders> ok cool
<totbwf> You can get pretty far with just scribbling cubes on paper and intuition
<ProofTechnique> That has been my vibe from skimming papers 
<totbwf> Most of the time you just `hfill` and make sure that the boundary conditions are all good
<monoidmusician> to show my newfound allegiance to the cause, is there a cool animation I could make for cubical type theory like I did with :hott: ?
<ProofTechnique> :party-wizard: works pretty well
<totbwf> Visualizing `hfills` can always look pretty cool
<monoidmusician> From the first link above ("a hands on introduction" on the HoTT site), it says:
> with the intuition is that `<i> a` is a function `\(i : I) -> a`. However for deep reasons the interval isn’t a type (as it isn’t fibrant) so we cannot write functions out of it directly and hence we have this special notation for path abstraction.
Can anyone elucidate what fibrant means in this context and/or point me to a proof of this fact? I tried to ctrl+F around the relevant paper but I couldn't find anything
I think it is related to this fact, from Agda's docs:
> The key idea of Cubical Type Theory is to add an interval type `I : Setω` (the reason this is in `Setω` is because it doesn’t support the `transp` and `hcomp` operations).
<ProofTechnique> https://ncatlab.org/nlab/show/two-level+type+theory makes some small amount of sense to me and gives "fibrant" some context.
<monoidmusician> ah, I see, that rings a bell now, I've skimmed that paper before
Regarding formalizing semisimplicial types, mentioned in the 2 level tt article:
> The problem of syntactically encoding the infinite amount of this coherence data remains unsolved to date.
I've been wondering if some kind of new primitive could be added to solve this problem, but I don't know enough about it to propose what it might look like …
<monoidmusician> Agda seems really cool
<ProofTechnique> I'm just gonna start explaining every decision I make at work by referencing the J rule and refusing to explain any further
<monoidmusician> "This reduces to a decision we made before" :wink:
<monoidmusician> now I really want to make a visual editor for Agda, but I have to finish my Dhall one first
<ArielG> I still struggle a bit with understanding cubical sets, to be honest.
But I think studying cubical sets to learn cubical type theory is a bit like studying categories with families to learn dependent type theory - it isn't really necessary and it's a bit of an overkill unless you are also interested in the denotational semantics of the language.
That being said, I think cubical sets is an amazing abstraction on its own regard - the way it uses the Yonneda lemma to consistently construct infinity-cubes is probably the most beautiful use of this lemma I've ever seen.
<totbwf> I've always found the notion of fibrant type to be super undocumented :disappointed:
<monoidmusician> it's probably one of those things that's so obvious that it goes without proof if you know the subject well, but is obscure to the rest of us

### Thursday, December 19th
<monoidmusician> I almost never watch talks on YouTube, but this looks to be fascinating: https://www.youtube.com/watch?v=B59Gy1nSzSE
<totbwf> There are some really excellent lectures on the Homotopy Type Theory Electronic Seminar Talks youtube channel
<totbwf> I normally don't like youtube talks that much either, but I find that they tend to dive much deeper into the intuition than the papers do

### Friday, December 20th
<masaeedu> i'm sad that all these comments will be lost in time
<masaeedu> like tears in rain
<ArielG> Found a video about Cubical Agda https://www.youtube.com/watch?v=AZ8wMIar-_c

### Saturday, December 21st
<totbwf> I like the explanation of HITs they use
<ArielG> I don't know - something about the fact that paths are themselves data is missing
<ArielG> I mean - you can basically consider points as merely 0-dimensional paths
<ArielG> Or - reflexivity paths, to be precise
<ArielG> So paths are a kind of a generalization of data, so when you define HITs you essentially define a type completely by inductively defining its path structure.
<ArielG> So `assoc` is not merely a law or an equality you have to respect when you define functions. `assoc` is literally data.
<ArielG> You can define structures using `assoc`, you can compute with it.
<ArielG> You can have lists of paths.
<totbwf> That is a good point
<totbwf> I wish they touched on fillers more too
<totbwf> That's the part that tripped me up the most
<monoidmusician> it was really interesting seeing pattern matching on (loop i, base), but I guess it makes a lot of sense from the infty-groupoid perspective: a function acts not only on the values of the type but also all the higher paths
<ArielG> I think that could serve as nice test for whether or not something is a "first-class object" : can you have lists of it?
<monoidmusician> is "first-class" related to category/proof-theoretic notions of "internalization"?
<ArielG> I think so, yes
<ArielG> Definitely
<ArielG> Actually, I think internalization is more like embedding
<ArielG> "first-class" is more like closure
<monoidmusician> embedding in what sense?
<ArielG> Like in domain specific languages
<ArielG> when you use the data of one language to describe the AST of another language.
<monoidmusician> that makes sense to me: programmers like first-class features so they don't have to develop ad-hoc external tools to abstract over it, all the existing machinery in the language still works for it
<monoidmusician> oh I see
<totbwf> Functional programming is just programming in a language who's type theory is the internal logic of a category with internal homs, what's the problem?
<ArielG> Sorry, actually what I described is not embedding, embedding is when you implement the DSL as a library, with pretty much the same syntax.
<ArielG> @totbwf Right, so it's an internalization in that sense, but not in the sense of group-objects for example.
<ArielG> Or maybe it is the same sense and I'm just missing something.
<totbwf> Yeah, I'm always pretty hazy on that sort of stuff<Paste>
<ArielG> I'm not sure what paths are, categorically
<totbwf> something something infinity groupoid something something cubical set
<totbwf> Yeah, I've been really struggling with this
<ArielG> To be more precise - what are path types.  If it is indeed an "internalized" notion then there should be an object which is the type of paths.
<ArielG> Like there is an exponential object for the type of functions.
<boarders> I would like an expanation which also makes it apparent why paths can't reasonably be fibrant in the model structure
<monoidmusician> my understanding is that paths are fibrant (hence why there are higher dimensional paths), but the interval isn't
<totbwf> IIRC there are some variants with fibrant intervals
<totbwf> I think Cartesian Cubical Type Theory?
<monoidmusician> okay, I haven't come across those if they exist
<totbwf> I've only read the Computational Cartesian Cubical Type Theory paper because I am a NuPRL fanboy but it looks interesting
<totbwf> But as to @ArielG's question, I've been looking for an explanation of that for quite some time now, and have always come up short
<totbwf> Though it is entirely possible that it there is an answer somewhere in the depths of ncatlab that went waaaay over my head
<monoidmusician> maybe this? https://ncatlab.org/nlab/show/path+space+object
<ArielG> It definitely appears somewhere in the cubical sets model, but I still struggle with it.
<boarders> sorry I wrote paths and did mean the interval object above
<totbwf> TBH, the cubical set stuff goes way over my head
<totbwf> Like, I have an intuition for how everything fits together, but I've yet to find a resource that has really resonated with me
<ArielG> Yeah I think I feel kinda the same
<ArielG> There is this weird duality there between faces of a hypercube and operations on a hypercube that I'm still trying to grasp my head around, and I don't feel like I can proceed before I properly understand it.
<totbwf> Sounds like we might be stuck on similar things lol
<boarders> Out of interest are you both familiar with simplicial sets?
<boarders> Because that is a good resource to get intuition from if it is not something you are familiar with and is a similar story to the cubical one is some respects
<totbwf> I understand the outlines of the idea
<totbwf> But I think I lack a really good intuition for it
<ArielG> It's pretty much the same idea but with simplices instead of cubes.
<ArielG> But cubical sets actually seem simpler.
<totbwf> Yeah, like I get the defintion, and I get why we use cubes instead of simplicies
<totbwf> I just think I need to better get a feel for presheaves TBH
<totbwf> Like, the definition makes sense, but the why of the thing has always felt a bit fuzzy
<totbwf> Doesn't help that I have almost zero background in topology lol 
<ArielG> I don't think topology is really necessary here.
<ArielG> It's a tool used mainly for topology, but by itself it is simply a purely categorical construction.
<ArielG> But maybe topology can give some intuition that is hard to get by other means.
<boarders>I think topology is very helpful in the sense of understand the way in which a simplicial set models a space and the way in which the simplicial operations correspond to the operations on a space
<boarders> or rather on something like a simplicial complex
<boarders> @totbwf: this is a good pure intuition reference: https://arxiv.org/pdf/0809.4221.pdf
<boarders> There are subtleties with cubes that I certainly don't understand yet but this still might be useful to you
<totbwf> This looks awesome
<ArielG> Yeah, thanks
<totbwf> I love how they refer the absolute beginner to Munkres lol
<boarders> this area is a great intuition for a bunch of stuff too (e.g. geometric realisation of a simplicial set is the quintessential example of a coend, the yoneda lemma for a simplicial set says maps from a n-simplex are in one-to-one correspondence with the n-simplex itself, they are the basis for the most common model of infinity cats). If you are already in the neighbourhood of computational models of homotopy type theory it is no bad place to check out :wink:
<totbwf> Yeah, this looks pretty sweet, definitely gonna give this a thorough read in the next few days
<ArielG> "the yoneda lemma for a simplicial set says maps from a n-simplex are in one-to-one correspondence with the n-simplex itself"
<ArielG> There is something pretty astonishing about that fact
<ArielG> It kinda forces you to coherently specifying your simplices because otherwise you break the functoriality of the the simplicial set.
<monoidmusician> is the inductive definition of the identity (with only the refl constructor) no longer valid/not equivalent to the path type in cubical type theory?
<monoidmusician> it's finally sinking in for me that (the definition of) a type is not just the inductive constructors of that type, it's also all the infty-groupoid structure bundled in there, and they're intimately related
<monoidmusician> which is to say that defining constructors of A=A while defining A  (as a HIT) really does make sense
<ArielG> The singleton identity type is still valid in the sense that you can still define it, but it would give you a type which isn't = (where = is the type of paths).
<ArielG> It's also not equivalent to = because = usually contains much more paths.
<ArielG> Actually I was wrong - they apparently are equivalent
<ArielG> But they seem to define it in a way which contains paths, so I don't understand how it is Martin-Löf's identity type.
[image.png]
<monoidmusician> yeah, that's a different definition than I was thinking of
<totbwf> Has anyone ever considered an octahedral type theory? It seems like you would get some of the same nice properties of cubes wrt dimensional shifts
<totbwf> They are dual after all
<totbwf> Plus, they are hypersimplexes, so that could have some useful applications?
<totbwf> I suppose the face maps wouldn't be nice... the faces of an n-octahedron aren't always n-1 octahedra
<ArielG> Is there any good overview of the connection of type theory to topology?
<monoidmusician> I'm halfway through the introduction to simplicial sets, it's quite good, but I'm not sure how much farther I can really go before I get lost
<monoidmusician> it's fascinating seeing the threads of HoTT peeking through
<monoidmusician> > Example 3.14 Notice that, unlike simplicial maps on simplicial complexes, morphisms on simplicial sets are not completely determined by what happens on vertices.
<monoidmusician> if I'm not totally off-base, I read this as related to the fact that functions' action on paths in HoTT is not solely determined by the action on points, since paths can be nontrivial and hold computational content
<boarders> interesting, so the martin-lof homogeneous identity type is equivalent to the homogenous one defined in terms of the Path type?
<boarders> @monoidmusician: precisely, it is completely analogous the defining higher inductive types! (e.g. maps out of S^1 are determined by a point and a self-equality of that point)
<monoidmusician> nice
<totbwf> Ive had a solid 7 hours with it on a plane, and its been really incredible
<totbwf> Kan conditions make so much more sense
<totbwf> Plus its fun to see kan extensions peeking through<Paste>
<totbwf> Like `hcomp/hfill` just witnesses the fact that you can extend morphisms on cubical horns to morphisms on the whole cube
<totbwf> Which coresponds to taking a bunch of partial path types, and filling in the rest of the bits to yield a proper path type
<monoidmusician> I think I proved that eq behaves like one expects in Cubical Agda:
```agda
data eq {A : Type ℓ} : A → A → Type ℓ where
  eq_refl : {x : A} → eq x x
eq_transp : ∀ {A : Type ℓ} {x y : A} → eq x y → ∀ (P : A → Type ℓ') → P x → P y
eq_transp {x = a} {y = a} eq_refl P Pa = Pa
eq_drec : ∀ {A : Type ℓ} {x : A} (P : ∀ {y : A} → eq x y → Type ℓ') → P eq_refl → ∀ {y : A} (prf : eq x y) → P prf
eq_drec {x = a} P Pa {y = a} eq_refl = Pa
eq_to_path : ∀ {A : Type ℓ} {x y : A} → eq x y → x ≡ y
eq_to_path {x = x} prf = eq_transp prf (λ y → x ≡ y) refl
path_to_eq : ∀ {A : Type ℓ} {x y : A} → x ≡ y → eq x y
path_to_eq {x = x} prf = subst (λ y → eq x y) prf eq_refl
dir1 : ∀ {A : Type ℓ} {x y : A} (prf : eq x y) → path_to_eq (eq_to_path prf) ≡ prf
dir1 {x = a} {y = a} eq_refl i = transportRefl eq_refl i
lem1 : ∀ {A : Type ℓ} {x : A} → subst (λ y → eq x y) refl eq_refl ≡ eq_refl {x = x}
lem1 {x = x} = substRefl {B = eq x} eq_refl
lem1' : ∀ {A : Type ℓ} {x : A} → eq_transp (subst (λ y → eq x y) refl eq_refl) (λ y → x ≡ y) refl ≡ eq_transp (eq_refl {x = x}) (λ y → x ≡ y) refl
lem1' {x = x} i = eq_transp (lem1 i) (λ y → x ≡ y) refl
lem2 : ∀ {A : Type ℓ} {x : A} → eq_transp eq_refl (λ y → x ≡ y) refl ≡ (refl {x = x})
lem2 = refl
inv_refl : ∀ {A : Type ℓ} {x : A} → eq_transp (subst (λ y → eq x y) refl eq_refl) (λ y → x ≡ y) refl ≡ (refl {x = x})
inv_refl = lem1' ∙ lem2
dir2 : ∀ {A : Type ℓ} {x y : A} (prf : x ≡ y) → eq_to_path (path_to_eq prf) ≡ prf
dir2 {x = x} = J (λ y prf → eq_to_path (path_to_eq prf) ≡ prf) inv_refl
eq_equiv : ∀ {A : Type ℓ} {x y : A} → Iso (x ≡ y) (eq x y)
eq_equiv = iso path_to_eq eq_to_path dir1 dir2
```
<monoidmusician> p.s. it's my first time working with Agda and the tools in Atom are pretty nice, works the first time ￼
<monoidmusician> monoidmusician 11:12 PM
@ArielG maybe you can glean some more insight about cut-elimination from this: https://mathoverflow.net/questions/42915/can-a-typing-judgment-admit-essentially-different-derivations

### Sunday, December 22nd
<monoidmusician> I've fried my brain for the night implementing relational parametricity, for natural numbers …
<monoidmusician> in general, we would not expect two proofs of relational parametricity for a function to be equal, is that correct?
<monoidmusician> or rather, we would, but that depends on the proof of parametricity being itself parametric, which seems like a pain to formalize
<monoidmusician> I might just propositionally truncate it and work with hSets
<monoidmusician> a proof of relational parametricity for `F : (X : U) -> (X -> X) -> X -> X` looks like
```agda
-- for two parameters
(X Y : U) ->
-- any relationship
(Rel : X -> Y -> U) ->
-- which lifts through the specified endofunctions
(f : x -> x) -> (G : y -> y) -> ((x : X) -> (y : Y) -> Rel x y -> Rel (f x) (g y)) ->
-- and holds on the specific base case
(x : X) -> (y : Y) -> Rel x y ->
-- also holds on the end result, no matter how many times F applies f to x
Rel (F X f x) (F Y g y)
```
<monoidmusician> it's almost trivial to turn this into a proof that such functions are generated by natural numbers in the obvious way, but without further assumptions I don't think you can just prove the desired result that parametric functions of the above form are in 1–1 correspondence with the natural numbers, due to the potentially proof-relevant parametricity result
<monoidmusician> possibly nonsensical question: can we quotient in  a way that doesn't change the higher path structure any more than is necessary?
<ArielG> What do you have in mind?
<ArielG> You mean that paths in the domain would be properly represented in the "quotient" instead of simply sent to reflexivity?
<ArielG> For example if there is `p1 : Path A x1 y1` and `p2 : Path A x2 y2` and there is `r : R(x1,x2)` (and by transport  `r' : R(y1,y2)`) then while `q(x1) = q(x2) = q(y1) = q(y2)` (let's call this point `t`), then instead of a 0-truncation you'll have distinct `q(p1) : Path (A/R) t t` and `q(p2) : Path (A/R) t t` ?
<ArielG> To be honest I think that's kinda what happens naturally if you don't add the 0-truncation, but I'm not sure.
<ArielG> I mean - `q  : A -> (A/R)` is a 0-constructor so it should already create a distinct path in A/R for each path in A (due to its functoriality).
<ArielG> So `A/R` already has a similar higher path structure to `A` (+ some extra paths for the quotient) and the only thing that "destroys" it is the 0-truncation.
<ArielG> So just omit the 0-truncation and I think you'll get exactly what you want.
<ArielG> Wait, actually I think there is something I don't understand regarding truncation.
<ArielG> For example - the definition of `isSet` is:
<ArielG> `(x,y : A) -> (p,q : x = y) -> p = q`
<ArielG> But all it says is that there is some higher dimensional path between `p` and `q`, it doesn't say that it is necessarily reflexivity.
<ArielG> So does h-truncation really destroy all the information above dimension h? because it doesn't really look like it does.
<ArielG> Though I'm probably missing something.
<gallais> It's a theorem that it should be enough. Not easy to prove though
<ArielG> In the HoTT book there is a lemma that the interval type is contractible.
<ArielG> Even though it definitely has an higher dimensional path.
<gallais> Is this not the result you are looking for?  https://github.com/agda/cubical/blob/master/Cubical/Foundations/Prelude.agda#L262
<ArielG> No, that only shows that h-props are h-sets.
<gallais> `(x,y : A) -> (p,q : x = y) -> p = q` this is saying that the equality paths on A are a prop.
<gallais> By the previous result there are also a set.
<gallais> i.e. the equalities between these equalities are also a prop.
<gallais> Etc. ad infinitum: all the levels are props.
<ArielG> But prop doesn't mean it's trivial.
<gallais> Does it not?
<ArielG> No - the interval type is also a prop.
<ArielG> I think the main thing truncation does is that by adding more paths you force all the functions from the truncated domain to respect those paths somehow, and if in the codomain there are no non-trivial higher paths then it forces the functions to send them all to reflexivity and their endpoints to the same value.
<ArielG> So it doesn't really "destroy" the higher path structure, but it kinda "pre-destroys" it, in the sense I've mentioned.
<ArielG> For example when you define functions from a quotient to a "proper" set (where there really is no higher path structure) it forces you to send all the values in the same class to the same image.
<monoidmusician> no that's right, interval is a prop and all of its equalities are trivial – the only way to relate zero to one is to go through the path added between them … the interval literally is just the unit type, but with a different definition
> <ArielG> But `seg : zero = one` isn't equal to `refl`
> <ArielG> Unless it does?
> <ArielG> But... how is that possible?
> <ArielG> I mean - they might be equal in the sense that there is a path between them, but that's just another higher dimensional path, isn't it?
> <monoidmusician> it's a path, and it's the only path between them

### Monday, December 23rd
<boarders> Can you manage to make sense of the contractibility of the interval in cubical agda
<boarders> you would need to be able to talk about the path type for Typeω which seems not possible?
<monoidmusician> we meant the user-defined interval, not the cubical one
<monoidmusician> this one: https://github.com/agda/cubical/blob/master/Cubical/HITs/Interval/Base.agda
<boarders> ahhhh ok
<monoidmusician> is there a way of saying two types in different universes are equal?
<boarders> sort of I think, you have to use: https://github.com/agda/agda-stdlib/blob/master/src/Level.agda
<boarders> This has come up for me in terms of isomorphism. If you try to prove the Yoneda lemma in the form that:
```
Nat(Hom(-,X), F) ≅ F X
```
<boarders> Then in any formalisation you will have that those two things live in different levels
<boarders> and so in order to state what you want to state you need to say that there is an isomorphism between then at the higher level
<boarders> But I'm not very informed on any of this so it should be taken with a huge pinch of salt
<monoidmusician> yeah, it's a little weird that functions can of course cross universes, but not equalities
<monoidmusician> speaking of universes, I found it surprising that function extensionality can result in a lower universe too
<boarders> Ah intereting, in what sense do you mean?
<monoidmusician> if you want to prove that `f g : ∀ (T : Type) -> T -> T` behave
the same, you can either prove they are equal directly (in which case the proof
is in `Type 1`) , or you can apply function extensionality and prove they are
equal when applied to any type (and that part of the proof is just in `Type`)
<monoidmusician> here's my parametricity work from the past day: https://gist.github.com/MonoidMusician/e20053551bb49343b90236ed69f0afb1
<monoidmusician> line 196 has the note about extensionality, maybe it's clearer in context
<monoidmusician> it's quite ironic that the one thing that everything is guaranteed to be parametric over (viz. universe levels) is the one thing that cubical equality cannot handle nicely …
<monoidmusician> actually, I take that back – `Type : Level -> Typeω`  is not
parametric over the universe level (obviously `Type 0` and `Type 1` are not
isomorphic)
<ArielG> I think what I find really confusing is the fact that equalities no longer mean merely equality of values.
<ArielG> Wait so any infinity-groupoid where all the objects are connected is the trivial groupoid?
<ArielG> That doesn't make sense to me.
<boarders> It is not where all the values are connected, that is just what is topologically called path-connected. It is the fact that all objects are continuously connected that makes it contractible.
<boarders> i.e. a term of type `Pi_(x, y : X) (x = y)` means the choice of path is continuous in x and y
<ArielG> I think I get it
<ArielG> Wait
<ArielG> No, not yet
<ArielG> How does it mean that?
<ArielG> I thought x=y is simply the type of paths between x and y
<ArielG> So it simply says "all 2 terms have a path between them"
<ArielG> So it is simply a groupoid with a single connected component.
<ArielG> There is nothing here that suggests those paths are all the identity path.
<monoidmusician> continuity of `Pi_(x y : X) (x = y)` means we get `Pi_(x y : X,
p q : x = y), p = q`, right?
<ArielG> Wait I think there's a proof of that in the book, I'll go check
<monoidmusician> wait I think it's not quite right
<monoidmusician> `Pi_(x y : X), x = y -> Pi_(p q : x = y), p = q`
<monoidmusician> nope that's not right either, ugh
<ArielG> No, that is right
<ArielG> each h-prop is an h-set
<monoidmusician> semantically I think it's right, but it's not the literal meaning of continuity
<ArielG> It is a verifiable fact which you can prove internally in MLTT
<ArielG> (which means you can also do it in HoTT/CuTT)
<ArielG> But again it's confusing because equality is just another path
<monoidmusician> `f : Pi (x y : X), x = y`
<monoidmusician> apply continuity, "for two pairs of inputs, if there is a path between the inputs, there is a path between their outputs"
<monoidmusician> `Pi (x1 y1 x2 y2 : X) -> x1 = x2 -> y1 = y2 -> f x1 y1 = f x2
y2`
<ArielG> true
<monoidmusician> (`f x1 y1 = f x2 y2` doesn't strictly typecheck, you just need to make use of the provided equalities)
<ArielG> Wait, I think I have a key for the intuition, but I might be wrong
<boarders> the continuity point is that every term we can define in type theory is automatically continuous so if we have a section in that pi type it is "automatically" continuous in its arguments
<ArielG> So - basically if a path has a path (from 1 dimension higher) to reflexivity, than it is practically indistinguishable from reflexivity, right?
<boarders> it is meant to connect up to the model via the fact that for a topological space X if you have a continuous choice of path between any two points then it is contractible
<boarders> as some geometric intuition why doesn't this hold for the sphere: well given any two points we can choose the shortest arc connecting them (called a geodesic) but what do we do when we want to connect the north pole and the south pole - we can make a choice but none of the choices we make is continuous
<boarders> (not sure if that is helpful or not)
<ArielG> Yeah I'm familiar with that geometric intuition, it's just that I keep forgetting that paths are basically just morphisms in a homotopy groupoids.
<ArielG> That is the whole source of the the higher dimensional structure.
<ArielG> So if something can be continuously transformed into something else then as far as we are concerned they are identical as morphisms.
<ArielG> But if that's the case - then why for example does the interval type proves functional extensionality but the unit type doesn't?
<ArielG> Damn there is much more than meets the eye in this theory, it's incredible.
<ArielG> Actually - I think it's not really the interval type that proves extensibility as much as the very ability to define the interval type.
<ArielG> For example in CuTT functional extensionality is a very trivial theorem (which doesn't require inductive types).
<monoidmusician> monoidmusician 6:37 PM
I'm trying to look at these proofs, which suggest that part of it is that computation holds definitionally? https://homotopytypetheory.org/2011/04/04/an-interval-type-implies-function-extensionality/
<monoidmusician> having quotients (with definitional reduction) is enough for funext, as is mentioned there; this is what Lean prover does
<ProofTechnique> Reading the last couple of days of chatter has been mind blowing. I'm so happy that this channel got so active
<monoidmusician> 'm trying to generalize this proof to Isos (so I can use it to relate types in different universes), but it gets a lot more complex, even though the cubical paths are downright trivial
```agda
liftPath :
  ∀ {X Y : Type ℓ} → (X≡Y : X ≡ Y) →
  ∀ {x1 x2 : X} {y1 y2 : Y} →
  PathP (λ i → X≡Y i) x1 y1 →
  PathP (λ i → X≡Y i) x2 y2 →
  (x1 ≡ x2) ≡ (y1 ≡ y2)
liftPath X≡Y x1≡y1 x2≡y2 i = (x1≡y1 i) ≡ (x2≡y2 i)
PathIso : ∀ {X : Type ℓ} {Y : Type ℓ′} → (X≅Y : Iso X Y) → X → Y → Type (ℓ-max ℓ ℓ′)
PathIso X≅Y x y = ((X≅Y .Iso.fun) x ≡ y) × (x ≡ (X≅Y .Iso.inv) y)
liftIso :
  ∀ {X : Type ℓ} {Y : Type ℓ′} → (X≅Y : Iso X Y) →
  ∀ {x1 x2 : X} {y1 y2 : Y} →
  PathIso X≅Y x1 y1 →
  PathIso X≅Y x2 y2 →
  Iso (x1 ≡ x2) (y1 ≡ y2)
liftIso X≅Y x1~y1 x2~y2 = record
  { fun = λ x1≡x2 → transport (λ i → (proj₁ x1~y1 i) ≡ (proj₁ x2~y2 i)) (cong (X≅Y .Iso.fun) x1≡x2)
  ; inv = λ y1≡y2 → transport (λ i → (proj₂ x1~y1 (~ i)) ≡ (proj₂ x2~y2 (~ i))) (cong (X≅Y .Iso.inv) y1≡y2)
  ; rightInv = λ _ → {!   !}
  ; leftInv = λ _ → {!   !}
  }
```
