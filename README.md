# Neuromorphic Hybrid Information Processing Architecture for High-performance Information Compression

### Abstract
The rapid development of artificial intelligence-of-things (AIOT) has led to a significant increase in intelligent nodes, presenting substantial challenges to inter-node communication. Semantic communication systems based on artificial neural networks (ANNs) have shown greater robustness than traditional Shannon systems, while unfriendly for hardware due to the high requirement on computing resources and low information compression efficiency. This work proposed a hybrid semantic system that employs ANNs for high-precision semantic extraction at the server and spiking neural networks (SNNs) for high-performance information compression in spatiotemporal dimension and semantic comprehending with low hardware cost at the edge. A hardware-friendly, event-based neuromorphic core has been developed with low hardware resource consumption and a high sampling rate for SNN deployment. The evaluation results indicate that the hybrid semantic system reduces the bandwidth by 95.8 \%, while maintaining a high sampling rate of 1000 Sa/s, outperforming traditional systems. Meanwhile, it enables a low entropy of the receiving end after four samples. Considering both bandwidth overhead and the entropy of the receiving end, the hybrid system achieves a high information compression ratio (ICR), surpassing the ANN-based system over 20 times. This work is expected to reveal the significance of neuromorphic computing in enabling high-performance information compression and transmission in semantic communication.


<p align="center">
<img src="https://github.com/black20441/euromorphic-Hybrid-Information-Processing-Architectureblob/061b15d46105f785c4e237f27c909c1c41ea67c4/figs/network_architecture.jpg" width="20%">
</p>


### Requirements (verilog simulation)
VCS O-2018.09-SP2_Full64

### Requirements (network training)
numpy==2.1.1
Requests==2.32.3
scikit_learn==1.5.2
scipy==1.14.1
spikingjelly==0.0.0.0.14
torch==2.4.1
torchaudio==2.4.1
torchsummary==1.5.1
torchvision==0.19.1
utils==1.0.2



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

