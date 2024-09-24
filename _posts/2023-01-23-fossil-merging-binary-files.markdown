---
layout: post
title:  "Merging binary files in Fossil - to do or not to do?"
categories: fossil merging
---

This is a note about merging (or not merging) binary files in Fossil.

## Scenario

Two users Marilyn and Jim update to latest and begin working on their versions of the repository. Marilyn, changes a binary file called DEMO and commits her changes. Meanwhile, Jim changes his DEMO and tries to commit his changes. When he does so, he is warned that a fork would result from his commit.

**Current Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3)) 
    id1((2))-..->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}

In this note, I look at different solutions to the problems arising when two different committers try to commit changes to the same binary file. This is just a note, not a published solution set. It presents my current thinking on the matter and will inevitably evolve as my understanding of Fossil grows.

<!--more-->

Here's the forum discussion that led to the current exploration:

[https://fossil-scm.org/forum/forumpost/6d7e1a942e](https://fossil-scm.org/forum/forumpost/6d7e1a942e)

In diagram 1.1 above, both Jim and Marilyn start with commit 2. Marilyn edits the binary, adds it and commits, creating commit 3. Jim, meanwhile, edits the same binary file, adds it and tries to commit. But, fossil warns him that the commit could result in a fork and tells him to either branch or add --allow-fork to his command.

At this point, Jim has some reasonable options:

1. He can stash his work, revert the changes, update to commit 3 (with Marilyn's changes), pop his stash, add and commit his changes as commit 4.
2. He can revert his changes and accept Marilyn's work by updating to commit 3.
3. He can fork the repository and allow multiple threads of development - commit 3 and 4.

There are probably other scenarios possible, but these are the most reasonable.

### Option 1 - Jim wants his changes to be the latest

**Current Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3)) 
    id1((2))-..->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}


**Desired Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3))-->id3((4))-.->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}


Where 4 is Jim's commit.

To achieve this desired situation, the following commands are executed by Jim:

```
fossil stash save -m "stashing j's changes"
fossil update
fossil stash pop
fossil add .
fossil commit -m "j's changes"
```

### Option 2 - Jim wants Marilyn's changes to be the latest

**Current Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3)) 
    id1((2))-..->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}


**Desired Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3))-.->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}

This is the simplest solution. Jim just reverts his changes and updates to Marilyn's commit, 3.

To achieve this desired situation, the following commands are executed by Jim:

```
fossil revert
fossil update
```

### Option 3 - Jim wants to create a fork

**Current Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3)) 
    id1((2))-..->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}


**Desired Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3))-..->STOP[ ]
    id1((2))--->id4((4))-.->STOP2[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
    style STOP2  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}


This is not what I would call an ideal situation as it will likely lead to a need to merge the fork later, but it's simple enough to create:

```
fossil commit --allow-fork -m "j's change"
```

#### Merging the fork

To merge the fork, just decide which fork needs to be merged and do it. In this case, Jim decides to merge Marilyn's fork back into his, with his changes being latest.

**Current Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3))-..->STOP[ ]
    id1((2))--->id4((4))-.->STOP2[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
    style STOP2  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}



**Desired Situation**

{% raw %}
<div class="mermaid">
flowchart LR
    START[ ]-->id1((2))-->id2((3))--->id5((5))
    id1((2))--->id4((4))-->id5((5))-.->STOP[ ]
    style START fill-opacity:0, stroke-opacity:0
    style STOP  fill-opacity:0, stroke-opacity:0
</div>
{% endraw %}

To achieve this desired situation, the following commands are executed by Jim:

```
fossil timeline
20:12:26 [3d37827c81] *CURRENT* j's changes (user: Jim tags: trunk)
20:11:46 [02a9bbd315] m's changes (user: Marilyn tags: trunk)

fossil checkout 02a9bbd315
DEMO

# get j's changed DEMO
fossil update 3d37827c81 DEMO
fossil merge
fossil add .
fossil commit -m "merging j's changes"
```

This is very much a note in progress. As I learn more and find better ways of doing things, I will update it.

\- will 
