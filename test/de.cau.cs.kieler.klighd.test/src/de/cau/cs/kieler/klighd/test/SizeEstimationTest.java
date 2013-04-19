/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2012 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.klighd.test;

import static de.cau.cs.kieler.klighd.KlighdConstants.KLIGHD_TESTING_EXPECTED_HEIGHT;
import static de.cau.cs.kieler.klighd.KlighdConstants.KLIGHD_TESTING_EXPECTED_WIDTH;
import static de.cau.cs.kieler.klighd.KlighdConstants.KLIGHD_TESTING_IGNORE;
import static de.cau.cs.kieler.klighd.KlighdConstants.KLIGHD_TESTING_HEIGHT;
import static de.cau.cs.kieler.klighd.KlighdConstants.KLIGHD_TESTING_WIDTH;

import java.util.Iterator;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterators;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.kgraph.text.KGraphStandaloneSetup;
import de.cau.cs.kieler.core.krendering.KRendering;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.util.Pair;
import de.cau.cs.kieler.kiml.klayoutdata.KShapeLayout;
import de.cau.cs.kieler.klighd.microlayout.Bounds;
import de.cau.cs.kieler.klighd.microlayout.PlacementUtil;
import de.cau.cs.kieler.pragmatics.test.common.runners.ModelCollectionTestRunner;
import de.cau.cs.kieler.pragmatics.test.common.runners.ModelCollectionTestRunner.BundleId;
import de.cau.cs.kieler.pragmatics.test.common.runners.ModelCollectionTestRunner.ModelFilter;
import de.cau.cs.kieler.pragmatics.test.common.runners.ModelCollectionTestRunner.ModelPath;
import de.cau.cs.kieler.pragmatics.test.common.runners.ModelCollectionTestRunner.StopOnFailure;

/**
 * Tests the node size estimation calculations in {@link PlacementUtil}. It does so by requiring the
 * properties {@link de.cau.cs.kieler.klighd.KlighdConstants#KLIGHD_TESTING_HEIGHT
 * KLIGHD_TESTING_HEIGHT} and {@link de.cau.cs.kieler.klighd.KlighdConstants#KLIGHD_TESTING_WIDTH
 * KLIGHD_TESTING_WIDTH} given for each {@link KText} occurring in a {@link KNode KNode's}
 * rendering, and by requiring
 * {@link de.cau.cs.kieler.klighd.KlighdConstants#KLIGHD_TESTING_EXPECTED_HEIGHT
 * KLIGHD_TESTING_EXPECTED_HEIGHT} and
 * {@link de.cau.cs.kieler.klighd.KlighdConstants#KLIGHD_TESTING_EXPECTED_WIDTH
 * KLIGHD_TESTING_EXPECTED_WIDTH} attached to the {@link KShapeLayout} of the {@link KNode}.
 * 
 * While the first implemented test ({@link #sizeDataPresentTest(KNode)}) acts as a precondition
 * test (presence of the properties, ...), the second one ({@link #sizeEstimationTest(KNode)})
 * actually tests the calculation logic, the third one ({@link #sizeEstimationTest2nd(KNode)})
 * re-runs the second one for checking the stability of the estimation result.
 * 
 * @author chsch
 */
@RunWith(ModelCollectionTestRunner.class)
@BundleId("de.cau.cs.kieler.klighd.test")
@ModelPath("sizeEstimationTests/")
@ModelFilter("*.kgt")
public class SizeEstimationTest {
    
    /**
     * Provides a {@link ResourceSet} in order to load the models properly.
     * 
     * @return the required {@link ResourceSet}
     */
    @ModelCollectionTestRunner.ResourceSet
    public static ResourceSet getResourceSet() {
        return KGraphStandaloneSetup.doSetup().getInstance(XtextResourceSet.class);
    }
    
    
    /**
     * This test acts as a precondition test, i.e. checks the presence of the required properties
     * for each {@link KNode} found in the model.
     * 
     * @param node the test input model
     */
    @Test
    @StopOnFailure
    public void sizeDataPresentTest(final KNode node) {
        for (Iterator<KNode> it = Iterators.filter(node.eAllContents(), KNode.class); it.hasNext();) {
            performSizeDataPresentTest(it.next());
        }
    }
    
    private void performSizeDataPresentTest(final KNode node) {
        if (node.getData(KRendering.class) == null) {
            // if no rendering is attached, there is nothing to test
            return;
        }
        
        KShapeLayout sl = node.getData(KShapeLayout.class);
        
        boolean isIgnored = sl.getProperties().get(KLIGHD_TESTING_IGNORE) != null;
        if (isIgnored) {
            return;
        }
        
        boolean containsSizeData = sl.getProperties().get(KLIGHD_TESTING_EXPECTED_HEIGHT) != null;
        containsSizeData &= sl.getProperties().get(KLIGHD_TESTING_EXPECTED_WIDTH) != null;
        
        if (!containsSizeData && !isIgnored) {
            throw new IllegalArgumentException(
                    "The KShapeLayout of the tested node must be equipped with properties"
                            + " named " + KLIGHD_TESTING_EXPECTED_HEIGHT + " and "
                            + KLIGHD_TESTING_EXPECTED_WIDTH
                            + " defining the related expected size of the node.");
        }
        
        for (Iterator<KText> it = Iterators.filter(node.eAllContents(), KText.class); containsSizeData
                && it.hasNext();) {
            KText text = it.next();
            containsSizeData &= text.getProperties().get(KLIGHD_TESTING_HEIGHT) != null;
            containsSizeData &= text.getProperties().get(KLIGHD_TESTING_WIDTH) != null;
        }
        
        if (!containsSizeData) {
            throw new IllegalArgumentException(
                    "All KText renderings must be equipped with properties named "
                            + KLIGHD_TESTING_HEIGHT + " and " + KLIGHD_TESTING_WIDTH
                            + " defining the assumed minimal size.");
        }
    }
    
    /**
     * This test is the actual size estimation calculation test.
     * 
     * @param node the test input model
     */
    @Test
    public void sizeEstimationTest(final KNode node) {
        // reveal all KNodes that are not to be ignored ...
        Iterator<KNode> it = Iterators.filter(
                Iterators.filter(node.eAllContents(), KNode.class),
                new Predicate<KNode>() {
                    public boolean apply(final KNode node) {
                        return node.getData(KShapeLayout.class).getProperties()
                                .get(KLIGHD_TESTING_IGNORE) == null;
                    }
                });
        
        // ... and perform the size estimation test on the valid ones
        for (; it.hasNext();) {
            performSizeEstimationTest(it.next());
        }
    }
    
    /**
     * This test checks the stability of the result by simply running the estimation a second time.
     * 
     * @param node the test input model
     */
    @Test
    public void sizeEstimationTest2nd(final KNode node) {
        sizeEstimationTest(node);
    }
    
    private static final float DELTA = 0.5f;
    
    private void performSizeEstimationTest(final KNode node) {
        if (node.getData(KRendering.class) == null) {
            // if no rendering is attached, there is nothing to test
            return;
        }
        
        KShapeLayout sl = node.getData(KShapeLayout.class);

        Bounds expected = Bounds.of(
            Float.parseFloat(sl.getProperties().get(KLIGHD_TESTING_EXPECTED_WIDTH).toString()),
            Float.parseFloat(sl.getProperties().get(KLIGHD_TESTING_EXPECTED_HEIGHT).toString())
        );
        
        Bounds actual = PlacementUtil.estimateSize(node);
        
        // put the estimated size into the node layout for testing the stability
        //  in the second run (second test; statement is useless in 2nd run)
        sl.setSize(actual.getWidth(), actual.getHeight());
        
        Pair<Boolean, Boolean> result = Bounds.compare(expected, actual, DELTA);
        
        String fragment = node.eResource().getURIFragment(node);
                
        if (!result.getFirst() && !result.getSecond()) {
            throw new AssertionError("Node '" + fragment + "': Expected node height of "
                    + expected.getHeight() + ", estimation gave " + actual.getHeight()
                    + ", expected node width of " + expected.getWidth() + ", estimation gave "
                    + actual.getWidth());
        }
        if (!result.getFirst()) {
            throw new AssertionError("Node '" + fragment + "': Expected node width of "
                    + expected.getWidth() + ", estimation gave " + actual.getWidth());
        }
        if (!result.getSecond()) {
            throw new AssertionError("Node '" + fragment + "': Expected node height of "
                    + expected.getHeight() + ", estimation gave " + actual.getHeight());
        }
    }
}
