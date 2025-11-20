# tsoding shaders

tsoding made a video of how to make shaders with C, ffmpeg and ppm file format.
Now I have an idea. What if you could parse GLSL to a ppm frames generating program.

Does it make sense to do something like this you ask? No.

Will I do it anyways? Yes.

## TODOs

- [ ] tokenizer for glsl
- [ ] parser for glsl
- [ ] frame generator/interpreter
- [ ] frames could be generated in parallel because I can move in time because I have control over time
- [ ] maybe include ffmpeg as dyn lib and give it the mem buffers directly
