# FBCD

The code is for paper ["Unsupervised multitemporal SAR image change detection via foreground-background collaborative optimization"](https://www.sciencedirect.com/science/article/pii/S1569843225006557#dfig2). by Weisong Li , Yinwei Li , Yiming Zhu , and Haipeng Wang.

To appear in International Journal of Applied Earth Observation and Geoinformation 2025 written by Weisong Li. Email: ws_li@usst.edu.cn; weisongli20@fudan.edu.cn

### Introduction
Multitemporal Synthetic Aperture Radar (SAR) image change detection (CD) represents a significant focus in remote sensing interpretation research. Recently, matrix low-rank decomposition theory has gained popularity in this field to exploit inherent structural information without requiring annotated data. However, existing approaches predominantly rely on an idealized assumption that defines changed regions as spatially localized and sparse. This assumption introduces critical theoretical limitations: its sensitivity to change scales results in sparsity constraints failing to characterize large-scale continuous changes and accumulating decomposition errors, while the neglect of low-rank coupling between changed regions and backgrounds further undermines theoretical completeness. To address these issues, we propose a Foreground and Background dual-path collaborative optimization CD framework, namely FBCD. Specifically, a foreground change saliency model is constructed under generalized low-rank constraints, integrating low-rank consistency and local correlation mechanisms to capture complex change patterns. In addition, a background stability model based on low-rank self-representation learning achieves precise background separation through multi-view consistency constraint. Once generating reconstructed difference map, a self-supervised graph-optimized label propagation algorithm is designed to transform binary classification into a graph partitioning optimization problem, which further improves the CD accuracy. Extensive experiments on seven bitemporal benchmark datasets validate the superiority of the proposed method: Compared to state-of-the-art approaches, it achieves average Kappa coefficient improvements of 2.50% for large-scale continuous changes and 4.48% for small-scale localized complex changes. Furthermore, the method also shows strong applicability in short-term time series datasets. 



#### Requirements:
The code is tested on Windows 10 with MATLAB R2024b.

#### Usage:
- put pre-generated DI maps into the directory '\data'. It is recommended to us log-ratio operator to genrate intial DI maps.
- put their ground truth into the directory '\GT'.
- run 'main.m'



## <a name="Citation"></a>Citation
If you find our work helpful for your research, please consider citing the following BibTeX entry:
```text
@article{li2026unsupervised,
  title={Unsupervised multitemporal SAR image change detection via foreground-background collaborative optimization},
  author={Li, Weisong and Li, Yinwei and Zhu, Yiming and Wang, Haipeng},
  journal={International Journal of Applied Earth Observation and Geoinformation},
  volume={146},
  pages={105008},
  year={2026},
  publisher={Elsevier}
}

```

If you have any problem, please contact ws_li@usst.edu.cn.




#### Related works
```text
@article{li2023spatial,
  title={Spatial correlation-constrained low-rank modeling for sar image change detection},
  author={Li, Weisong and Wang, Haipeng and Ma, Peifeng},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  volume={62},
  pages={1--15},
  year={2023},
  publisher={IEEE}
}

@article{li2025unsupervised,
  title={Unsupervised SAR Image Change Detection via Structure Feature-based Self-Representation Learning},
  author={Li, Weisong and Li, Yinwei and Zhu, Yiming and Wang, Haipeng},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  year={2025},
  publisher={IEEE}
}

```

