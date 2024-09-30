# Neuromorphic-Hybrid-Information-Processing-Architecture

<p align="center">
<img src="https://github.com/black20441/euromorphic-Hybrid-Information-Processing-Architectureblob/061b15d46105f785c4e237f27c909c1c41ea67c4/figs/network_architecture.jpg" width="20%">
</p>


Folder Structure
```
│Hardware/
├──rtl/
│  ├── TOP_snn.v %% (top level design)
│  ├── spike_code converter.v 
│  ├── AER_coding.v %% (spike encoder)
│  ├── TOP_conv.v %% (Conv PE)
│  ├── TOP_fc.v %% (FC PE)
│  ├── pe_fc2_layer1.v %% (FC PE)
│  ├── ...
├──frontend_file.list/
├──vcs/
│  ├── simfile
│  ├── testbench
│  ├── ......
│Software/
├──snncom/
│  ├── cifar10
│  │   ├── SNNCom_ANN.ipynb
│  │   ├── SNNCom_ANN+SNN.ipynb
│  │   ├── SNNCom_SNN.ipynb
│  │   ├── ......
│  ├── MNIST
│  │   ├── SNNCom_ANN.ipynb
│  │   ├── SNNCom_ANN+SNN.ipynb
│  │   ├── SNNCom_SNN.ipynb
│  │   ├── ......
│  ├── speechcommands
│  │   ├── SNNCom_ANN.ipynb
│  │   ├── SNNCom_ANN+SNN.ipynb
│  │   ├── SNNCom_SNN.ipynb
│  │   ├── ......
│  ├── ecg
│  │   ├── SNNCom_ANN.ipynb
│  │   ├── SNNCom_ANN+SNN.ipynb
│  │   ├── SNNCom_SNN.ipynb
│  │   ├── ......
├──requirements.txt
```

Neuromorphic Hybrid Information Processing Architecture for High-performance Information Compression
